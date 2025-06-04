# frozen_string_literal: true

module ApiTokenAuthentication
  extend ActiveSupport::Concern

  included do
    skip_before_action :verify_authenticity_token # disable CSRF for API

    before_action :authenticate
  end

  private

  def authenticate
    # Bearer <token>
    token = request.headers['Authorization'].to_s.split(' ').last
    api_token = token.present? ? ApiToken.find_by(token:) : nil
    return unless api_token

    api_token.used_now!
    @current_user = api_token.user
  end
end
