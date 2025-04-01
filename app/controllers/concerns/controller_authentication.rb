# frozen_string_literal: true

module ControllerAuthentication
  extend ActiveSupport::Concern

  included do
    before_action :resume_session
    before_action :require_authentication
  end

  class_methods do
    def allow_only_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
      before_action :redirect_if_authenticated, **options
    end
  end

  private

  def require_authentication
    request_authentication unless Current.user
  end

  def redirect_if_authenticated
    redirect_to dashboard_url if Current.user
  end

  def resume_session
    Current.session ||= find_session_by_cookie
  end

  def find_session_by_cookie
    UserSession.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
  end

  def request_authentication
    session[:return_to_after_authenticating] = request.url

    redirect_to sign_in_url
  end

  def after_authentication_url
    session.delete(:return_to_after_authenticating) || dashboard_url
  end

  def start_new_session_for(user)
    user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
      Current.session = session

      cookies.signed[:session_id] = {
        expires:   2.weeks.from_now.utc,
        httponly:  true,
        same_site: :lax,
        secure:    Rails.configuration.force_ssl,
        value:     session.id
      }
    end
  end

  def terminate_session
    Current.session.destroy

    cookies.delete(:session_id)
  end
end
