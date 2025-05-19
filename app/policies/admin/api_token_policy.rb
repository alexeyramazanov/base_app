# frozen_string_literal: true

module Admin
  class ApiTokenPolicy < ApplicationPolicy
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

    def create?
      true
    end

    def destroy?
      true
    end
  end
end
