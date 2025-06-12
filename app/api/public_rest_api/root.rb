# frozen_string_literal: true

module PublicRestApi
  class Root < Grape::API
    include ExceptionHandlers

    PUBLIC_ROUTES = %w[/public_api/swagger_doc.json].freeze

    helpers Helpers::AuthenticationHelpers,
            Helpers::AuthorizationHelpers,
            Helpers::ErrorHelpers,
            Helpers::PaginationHelpers

    format :json

    before do
      authenticate!
    end

    after do
      verify_pundit_authorization!
    end

    # newer versions should be mounted before older ones
    mount V2::Root
    mount V1::Root

    add_swagger_documentation(
      doc_version:          '1.0.0',
      info:                 {
        title: 'Public API'
      },
      schemes:              %w[development test].include?(Rails.env) ? %w[http] : %w[https],
      host:                 proc { |request| request.host_with_port },
      security_definitions: {
        APIKeyHeader: {
          type: 'apiKey',
          in:   'header',
          name: 'Authorization'
        }
      },
      security:             [
        {
          APIKeyHeader: []
        }
      ]
    )
  end
end
