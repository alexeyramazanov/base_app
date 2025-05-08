# frozen_string_literal: true

module Admin
  class BaseController < ActionController::Base # rubocop:disable Rails/ApplicationController
    include Pundit::Authorization
    include ControllerAdminAuthentication

    allow_browser versions: :modern

    after_action :verify_pundit_authorization

    layout 'admin'

    private

    def verify_pundit_authorization
      if action_name == 'index'
        verify_policy_scoped
      else
        verify_authorized
      end
    end

    def pundit_user
      Current.admin_user
    end

    def policy_scope(scope, policy_scope_class: nil)
      super([:admin, scope], policy_scope_class:)
    end

    def authorize(record, query = nil, policy_class: nil)
      super([:admin, record], query, policy_class:)
    end
  end
end
