# frozen_string_literal: true

class UserSessionPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      raise Pundit::NotAuthorizedError
    end
  end

  def destroy?
    record.user_id == user.id
  end
end
