# frozen_string_literal: true

module PublicRestApi
  module V1
    class Files < Grape::API
      resources :files do # rubocop:disable Metrics/BlockLength
        # GET /files
        desc 'List files',
             is_array:   true,
             success:    {
               message: 'Files list',
               model:   Entities::V1::File
             },
             failure:    Helpers::ErrorHelpers.failures(401, 500),
             deprecated: true
        get do
          files = policy_scope(UserFile)

          present files, with: Entities::V1::File
        end

        route_param :id do
          # GET /files/:id/download
          desc 'Return a URL for downloading a file',
               success: {
                 message: 'File with URL',
                 model:   Entities::V1::FileDownload
               },
               failure: Helpers::ErrorHelpers.failures(401, 404, 500)
          params do
            requires :id, type: String, desc: 'File ID', documentation: { type: 'integer' }
          end
          get '/download' do
            file = policy_scope(UserFile).find(params[:id])

            present file, with: Entities::V1::FileDownload
          end
        end
      end
    end
  end
end
