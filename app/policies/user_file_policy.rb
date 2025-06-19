# frozen_string_literal: true

class UserFilePolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(user:)
    end
  end

  def index?
    true
  end

  def show?
    belongs_to_user?
  end

  def new?
    belongs_to_user?
  end

  def create?
    belongs_to_user?
  end

  def edit?
    belongs_to_user?
  end

  def update?
    belongs_to_user?
  end

  def destroy?
    belongs_to_user?
  end

  def s3_params?
    true
  end

  def preview?
    belongs_to_user? && record.ready?
  end

  def download?
    belongs_to_user? && record.ready?
  end

  private

  def belongs_to_user?
    record.user_id == user.id
  end
end
