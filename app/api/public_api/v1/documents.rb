# frozen_string_literal: true

module PublicApi
  module V1
    class Documents < Grape::API
      resources :documents do

        # GET /documents
        desc 'List documents'
        get do
          Document.all
        end
      end
    end
  end
end
