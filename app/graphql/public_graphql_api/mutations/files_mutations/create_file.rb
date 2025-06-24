# frozen_string_literal: true

module PublicGraphqlApi
  module Mutations
    module FilesMutations
      class CreateFile < BaseMutation
        argument :data, String, required: true, description: 'The file base64 encoded content.'
        argument :file_name, String, required: true, description: 'The file name.'

        field :file, Types::FileType, null: false, description: 'The newly created file.'

        def resolve(file_name:, data:)
          authenticate!

          file = Shrine.data_uri(data, filename: file_name)
          user_file = current_user.user_files.new(attachment: file)
          authorize user_file, :create?

          if user_file.save
            { file: user_file }
          else
            raise_model_validation_error!(user_file)
          end
        rescue Shrine::Plugins::DataUri::ParseError
          raise_simple_validation_error!(['Invalid file'])
        end
      end
    end
  end
end
