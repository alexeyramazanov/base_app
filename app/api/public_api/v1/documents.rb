# frozen_string_literal: true

module PublicApi
  module V1
    class Documents < Grape::API
      resources :documents do

        # GET /documents
        desc 'List documents'
        get do
          policy_scope(Document)
        end
      end
    end
  end
end
