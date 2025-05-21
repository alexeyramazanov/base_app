# frozen_string_literal: true

module PublicApi
  module V2
    class Documents < Grape::API
      resources :documents do # rubocop:disable Metrics/BlockLength
        extend Helpers::ErrorHelper

        # GET /documents
        desc 'List documents',
             success: {
               message:  'Documents list',
               model:    Entities::V2::Document,
               examples: {
                 'application/json': [
                   { id: 241, user_id: 15, file_name: 'image.png', file_size: 78_325 }
                 ]
               }
             },
             failure: failures(401, 500)
        get do
          documents = policy_scope(Document)

          present documents, with: Entities::V2::Document
        end

        desc 'Create a document',
             success: {
               message:  'Document',
               model:    Entities::V2::Document,
               examples: {
                 'application/json': { id: 241, user_id: 15, file_name: 'image.png', file_size: 78_325 }
               }
             },
             failure: failures(401, 500)
        params do
          requires :file_name, type: String, desc: 'File name', documentation: { type: 'string', default: 'image.png' }
          requires :data, type: String, desc: 'Base64 encoded file content',
                   documentation: { type:    'string',
                                    default: 'data:image/png;base64,iVBORw0KGgo...' }
        end
        post do
          declared_params = declared(params)
          file = Shrine.data_uri(declared_params[:data], filename: declared_params[:file_name])
          document = current_user.documents.new(file:)
          authorize document, :create?

          if document.save
            present document, with: Entities::V2::Document
          else
            error_unprocessable_entity!(*document.errors.full_messages)
          end
        end
      end
    end
  end
end
