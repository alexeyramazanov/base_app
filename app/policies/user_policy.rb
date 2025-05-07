# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      raise Pundit::NotAuthorizedError
    end
  end

  def show?
    record == user
  end

  def edit?
    update?
  end

  def update?
    record == user
  end
end
