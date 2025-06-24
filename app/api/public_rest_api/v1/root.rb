# frozen_string_literal: true

module PublicRestApi
  module V1
    class Root < Grape::API
      version 'v1', 'v2', using: :path

      mount Files
    end
  end
end
