# frozen_string_literal: true

module Admin
  class AdminSessionPolicy < BasePolicy
    class Scope < ApplicationPolicy::Scope
      def resolve
        raise Pundit::NotAuthorizedError
      end
    end

    def destroy?
      record.admin_user_id == user.id
    end
  end
end
