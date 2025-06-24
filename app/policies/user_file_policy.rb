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
  alias new? show?
  alias create? show?
  alias edit? show?
  alias update? show?
  alias destroy? show?

  def s3_params?
    true
  end

  def preview?
    belongs_to_user? && record.ready?
  end
  alias download? preview?

  private

  def belongs_to_user?
    record.user_id == user.id
  end
end
