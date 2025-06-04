# frozen_string_literal: true

class BaseAppSchema < GraphQL::Schema
  use GraphQL::Dataloader
  query Types::QueryType
  mutation Types::MutationType

  max_query_string_tokens 5000
  validate_max_errors 100
  default_max_page_size 10
end
