# frozen_string_literal: true

module PublicApi
  module V1
    class Documents < Grape::API
      resources :documents do # rubocop:disable Metrics/BlockLength
        extend Helpers::ErrorHelper

        # GET /documents
        desc 'List documents',
             success:    {
               message:  'Documents list',
               model:    Entities::V1::Document,
               examples: {
                 'application/json': [
                   { id: 241, user_id: 15, file_name: 'image.png' }
                 ]
               }
             },
             failure:    failures(401, 500),
             deprecated: true
        get do
          documents = policy_scope(Document)

          present documents, with: Entities::V1::Document
        end

        route_param :id do
          # GET /documents/:id/download
          desc 'Return a URL for downloading a document',
               success: {
                 message:  'Document with URL',
                 model:    Entities::V1::DocumentDownload,
                 examples: {
                   'application/json': {
                     id:  241,
                     url: 'https://baseapp.s3.us-east-1.amazonaws.com/documents/image.png?X-Amz-Algorithm=AWS4-HMAC-SHA256'
                   }
                 }
               },
               failure: failures(401, 404, 500)
          params do
            requires :id, type: String, desc: 'Document ID', documentation: { type: 'integer' }
          end
          get '/download' do
            document = policy_scope(Document).find(declared(params)[:id])

            present document, with: Entities::V1::DocumentDownload
          end
        end
      end
    end
  end
end
