# frozen_string_literal: true

module Admin
  class UserPolicy < ApplicationPolicy
    class Scope < ApplicationPolicy::Scope
      def resolve
        scope.all
      end
    end

    def index?
      true
    end

    def show?
      true
    end

    def request_user_stats?
      true
    end
  end
end
