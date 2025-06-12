# frozen_string_literal: true

module PublicRestApi
  module V1
    class Documents < Grape::API
      resources :documents do # rubocop:disable Metrics/BlockLength
        # GET /documents
        desc 'List documents',
             is_array:   true,
             success:    {
               message: 'Documents list',
               model:   Entities::V1::Document
             },
             failure:    Helpers::ErrorHelpers.failures(401, 500),
             deprecated: true
        get do
          documents = policy_scope(Document)

          present documents, with: Entities::V1::Document
        end

        route_param :id do
          # GET /documents/:id/download
          desc 'Return a URL for downloading a document',
               success: {
                 message: 'Document with URL',
                 model:   Entities::V1::DocumentDownload
               },
               failure: Helpers::ErrorHelpers.failures(401, 404, 500)
          params do
            requires :id, type: String, desc: 'Document ID', documentation: { type: 'integer' }
          end
          get '/download' do
            document = policy_scope(Document).find(params[:id])

            present document, with: Entities::V1::DocumentDownload
          end
        end
      end
    end
  end
end
