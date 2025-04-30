# frozen_string_literal: true

module AdminAuthentication
  extend ActiveSupport::Concern

  included do
    has_secure_password validations: false, reset_token: false

    normalizes :email, with: ->(e) { e.strip.downcase }

    attr_accessor :password_changed

    validates :email, presence: true, uniqueness: true
    # length replaces `presence` validation
    # `password_changed` flag is used to trigger validations on empty passwords
    validates :password, length: { minimum: 6, maximum: 40 },
                         if:     -> { new_record? || changes[:password_digest] || password_changed }
    validates :password, confirmation: true,
                         if:           lambda { |record|
                record.password.present? && (new_record? || changes[:password_digest] || password_changed)
              }
    # `confirmation: true` is executed only if attribute is present, so we have to check presence additionally
    validates :password_confirmation, presence: true,
                                      if:       -> { new_record? || changes[:password_digest] || password_changed }
    validate { |record| record.errors.add(:password, :blank) if record.persisted? && record.password_digest.blank? }

    # TODO: add support for expiring all sessions except current one
    has_many :sessions, class_name: 'AdminSession', dependent: :destroy
  end

  class_methods do
    def authenticate(params)
      user = find_by(email: params[:email])
      return [:not_found, nil] unless user

      if user.authenticate_password(params[:password])
        [:success, user]
      else
        [:invalid_password, nil]
      end
    end
  end
end
