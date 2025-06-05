# frozen_string_literal: true

module PublicGraphqlApi
  module Types
    class PublicActiveRecordType < BaseObject
      def self.authorized?(_object, _context)
        true
      end
    end
  end
end
