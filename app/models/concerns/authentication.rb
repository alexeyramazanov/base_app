# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern

  included do
    # TODO: store encrypted activate and reset tokens
    # default password reset implementation allows infinite number of tokens and exposes some internal info in token
    has_secure_password validations: false, reset_token: false

    normalizes :email, with: ->(e) { e.strip.downcase }

    enum :activation_state, { pending: 'pending', active: 'active' }, default: :pending,
         scopes: false, instance_methods: false, validate: true

    attr_accessor :password_changed

    validates :email, presence: true, uniqueness: true
    # length replaces presence validation, `password_changed` flag is used to prevent empty passwords
    validates :password, length: { minimum: 6, maximum: 40 },
                         if:     -> { new_record? || changes[:password_digest] || password_changed }
    validates :password, confirmation: true,
                         if:           -> { new_record? || changes[:password_digest] || password_changed }
    # `confirmation: true` is executed only if attribute is present, so we have to check presence additionally
    validates :password_confirmation, presence: true,
                                      if:       -> { new_record? || changes[:password_digest] || password_changed }
    validate { |record| record.errors.add(:password, :blank) if record.password_digest.blank? }

    # TODO: add support for expiring all sessions except current one
    has_many :sessions, class_name: 'UserSession', dependent: :destroy
  end

  class_methods do # rubocop:disable Metrics/BlockLength
    def authenticate(params)
      user = find_by(email: params[:email])
      return [:not_found, nil] unless user

      return [:activation_required, nil] if user.activation_state != 'active'

      if user.authenticate_password(params[:password])
        [:success, user]
      else
        [:invalid_password, nil]
      end
    end

    def activate_account(token)
      user = find_by(activation_token: token)
      return unless user

      return if user.activation_state != 'pending'
      return unless user.activation_token_expires_at&.future?

      user.assign_attributes(
        activation_state:            'active',
        activation_token:            nil,
        activation_token_expires_at: nil
      )
      user.save!(validate: false)

      user
    end

    def find_by_reset_password_token(token)
      user = find_by(reset_password_token: token)
      return unless user

      return unless user.reset_password_token_expires_at&.future?

      user
    end
  end

  def update_password(params)
    assign_attributes(params.merge(password_changed: true))
    return false unless valid?

    assign_attributes(
      reset_password_token:            nil,
      reset_password_token_expires_at: nil
    )
    save!(validate: false)

    self
  end

  def send_activation_link
    return if activation_state != 'pending'

    assign_attributes(
      activation_token:            SecureRandom.hex(20).encode('UTF-8'),
      activation_token_expires_at: 2.weeks.from_now
    )
    save!(validate: false)

    AuthenticationMailer.with(user: self).activation_link.deliver_later
  end

  def send_password_reset_link
    return send_activation_link if activation_state == 'pending'

    assign_attributes(
      reset_password_token:            SecureRandom.hex(20).encode('UTF-8'),
      reset_password_token_expires_at: 15.minutes.from_now
    )
    save!(validate: false)

    AuthenticationMailer.with(user: self).reset_password.deliver_later
  end
end
