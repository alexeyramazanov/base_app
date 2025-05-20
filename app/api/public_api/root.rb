# frozen_string_literal: true

module PublicApi
  class Root < Grape::API
    include ExceptionHandlers

    helpers Helpers::AuthenticationHelper,
            Helpers::PunditHelper,
            Helpers::ErrorHelper

    format :json

    before do
      authenticate!
    end

    after do
      verify_pundit_authorization!
    end

    mount V1::Root

    add_swagger_documentation(
      doc_version:          '1.0.0',
      info:                 {
        title: 'BaseApp RESTful API'
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
