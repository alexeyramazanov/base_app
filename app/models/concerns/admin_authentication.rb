# frozen_string_literal: true

module AdminAuthentication
  extend ActiveSupport::Concern

  included do
    has_secure_password validations: false, reset_token: false

    normalizes :email, with: ->(e) { e.strip.downcase }

    validates :email, presence: true, uniqueness: true
    validates :password, length: { minimum: 6, maximum: 40 }, if: -> { new_record? || changes[:password_digest] }

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
