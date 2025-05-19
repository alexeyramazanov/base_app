# frozen_string_literal: true

module PublicApi
  module V1
    class Documents < Grape::API
      resources :documents do

        # GET /documents
        desc 'List documents'
        get do
          documents = policy_scope(Document)

          present documents, with: Entities::V1::Document
        end
      end
    end
  end
end
