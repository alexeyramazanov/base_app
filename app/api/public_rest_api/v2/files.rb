# frozen_string_literal: true

module PublicRestApi
  module V2
    class Files < Grape::API
      resources :files do # rubocop:disable Metrics/BlockLength
        helpers Helpers::PaginationHelpers

        # GET /files
        desc 'List files',
             success: {
               message: 'Files list',
               model:   Entities::V2::PaginatedFiles
             },
             failure: Helpers::ErrorHelpers.failures(401, 500)
        params do
          use :pagination
        end
        get do
          paginated_data = paginate(policy_scope(UserFile).order(id: :desc))

          present paginated_data, with: Entities::V2::PaginatedFiles
        end

        desc 'Create a file',
             success: {
               message: 'File',
               model:   Entities::V2::File
             },
             failure: Helpers::ErrorHelpers.failures(401, 422, 500)
        params do
          requires :file_name, type: String, desc: 'File name',
                   documentation: { type: 'string', default: 'image.png' }
          requires :data, type: String, desc: 'Base64 encoded file content',
                   documentation: { type: 'string', default: 'data:image/png;base64,iVBORw0KGgo...' }
        end
        post do
          file = Shrine.data_uri(params[:data], filename: params[:file_name])
          user_file = current_user.user_files.new(attachment: file)
          authorize user_file, :create?

          if user_file.save
            present user_file, with: Entities::V2::File
          else
            error_unprocessable_entity!(*user_file.errors.full_messages)
          end
        rescue Shrine::Plugins::DataUri::ParseError
          error_unprocessable_entity!('Invalid file')
        end
      end
    end
  end
end
