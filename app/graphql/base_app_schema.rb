# frozen_string_literal: true

class BaseAppSchema < GraphQL::Schema
  use GraphQL::Dataloader
  mutation Types::MutationType
  query Types::QueryType

  max_query_string_tokens 5000
  validate_max_errors 100
  default_max_page_size 10
end
