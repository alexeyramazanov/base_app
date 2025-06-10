# frozen_string_literal: true

module PublicGraphqlApi
  module Types
    class VersionType < PublicActiveRecordType
      field :version, String, null: false
    end
  end
end
