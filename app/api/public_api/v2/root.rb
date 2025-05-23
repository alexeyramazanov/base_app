# frozen_string_literal: true

module PublicApi
  module V2
    class Root < Grape::API
      version 'v2', using: :path

      mount Documents
    end
  end
end
