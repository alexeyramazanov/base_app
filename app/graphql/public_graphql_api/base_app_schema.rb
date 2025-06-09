# frozen_string_literal: true

module PublicGraphqlApi
  class BaseAppSchema < GraphQL::Schema
    include ErrorHandlers::Rescue

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
    def self.object_from_id(object_id, context)
      gid = GlobalID.parse(object_id)
      raise_simple_validation_error!(['Invalid ID format']) unless gid

      object = GlobalID::Locator.locate(gid)
      Pundit.authorize(context[:current_user], object, :show?)

      object
    end

    # Union and Interface Resolution
    def self.resolve_type(_abstract_type, application_object, _context)
      case application_object
      when Document
        Types::DocumentType
      else
        # TODO: change exception to standard one
        # TODO: write spec
        raise("Unexpected object: #{application_object}")
      end
    end
  end
end
