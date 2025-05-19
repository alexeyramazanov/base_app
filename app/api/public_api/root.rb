# frozen_string_literal: true

module PublicApi
  class Root < Grape::API
    format :json

    mount V1::Root
  end
end
