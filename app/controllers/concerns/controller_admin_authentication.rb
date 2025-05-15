# frozen_string_literal: true

module ControllerAdminAuthentication
  extend ActiveSupport::Concern

  included do
    before_action :resume_session
    before_action :redirect_if_user
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
    request_authentication unless Current.admin_user
  end

  def redirect_if_user
    redirect_to dashboard_url if cookies.signed[:session_id]
  end

  def redirect_if_authenticated
    redirect_to admin_dashboard_url if Current.admin_user
  end

  def resume_session
    Current.session ||= find_session_by_cookie
  end

  def find_session_by_cookie
    session = AdminSession.find_by(id: cookies.signed[:admin_session_id]) if cookies.signed[:admin_session_id]

    cookies.delete(:admin_session_id) unless session

    session
  end

  def request_authentication
    session[:return_to_after_authenticating] = request.url

    redirect_to admin_sign_in_url
  end

  def after_authentication_url
    session.delete(:return_to_after_authenticating) || admin_dashboard_url
  end

  def start_new_session_for(admin)
    admin.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
      Current.session = session

      cookies.signed[:admin_session_id] = {
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

    cookies.delete(:admin_session_id)
  end
end
