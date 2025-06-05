# frozen_string_literal: true

module PublicGraphqlApi
  class BaseAppSchema < GraphQL::Schema
    include PublicGraphqlApi::ErrorHandlers::Rescue

    use GraphQL::Dataloader
    query Types::QueryType
    mutation Types::MutationType

    max_query_string_tokens 5000
    validate_max_errors 100
    default_max_page_size 10

    # Relay-style Object Identification:

    # Return a string UUID for `object`
    def self.id_from_object(application_object, _graphql_type, _context)
      application_object.to_gid_param
    end

    # Given a string UUID, find the `object`
    def self.object_from_id(object_id, _context)
      GlobalID.find(object_id)
    end

    # Union and Interface Resolution
    def self.resolve_type(_abstract_type, application_object, _context)
      case application_object
      when Document
        Types::DocumentType
      else
        raise("Unexpected object: #{application_object}")
      end
    end
  end
end
