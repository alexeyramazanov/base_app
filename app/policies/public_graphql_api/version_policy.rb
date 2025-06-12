# frozen_string_literal: true

module PublicGraphqlApi
  class VersionPolicy < ::ApplicationPolicy
    def show?
      true
    end
  end
end
