# frozen_string_literal: true

module PublicApi
  module V1
    class Root < Grape::API
      version 'v1', using: :path

      mount Documents
    end
  end
end
