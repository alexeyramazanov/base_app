# frozen_string_literal: true

module Admin
  class DashboardController < BaseController
    def show
      authorize :dashboard
    end
  end
end
