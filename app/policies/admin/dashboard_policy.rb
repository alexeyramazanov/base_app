# frozen_string_literal: true

module Admin
  class DashboardPolicy < Admin::BasePolicy
    def show?
      true
    end
  end
end
