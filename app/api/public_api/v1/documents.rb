# frozen_string_literal: true

module PublicApi
  module V1
    class Documents < Grape::API
      resources :documents do
        extend PublicApi::Helpers::ErrorHelper

        # GET /documents
        desc 'List documents',
             success: {
               model:    PublicApi::Entities::V1::Document,
               examples: {
                 'application/json': [
                   { id: 241, user_id: 15, file_name: 'image.png' }
                 ]
               }
             },
             failure: failures(401, 500)
        get do
          documents = policy_scope(Document)

          present documents, with: PublicApi::Entities::V1::Document
        end
      end
    end
  end
end
