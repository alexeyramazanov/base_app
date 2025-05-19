# frozen_string_literal: true

module PublicApi
  class Root < Grape::API
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
  end
end
