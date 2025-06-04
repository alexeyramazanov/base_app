# frozen_string_literal: true

module Helpers
  module AuthorizationHelpers
    include Pundit::Authorization

    def current_user
      context[:current_user]
    end
  end
end
