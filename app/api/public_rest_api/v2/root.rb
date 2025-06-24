# frozen_string_literal: true

module PublicRestApi
  module V2
    class Root < Grape::API
      version 'v2', using: :path

      mount Files
    end
  end
end
