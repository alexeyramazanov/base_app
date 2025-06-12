# frozen_string_literal: true

module PublicGraphqlApi
  module Mutations
    module DocumentsMutations
      class CreateDocument < BaseMutation
        argument :data, String, required: true, description: 'The document base64 encoded file content.'
        argument :file_name, String, required: true, description: 'The document file name.'

        field :document, Types::DocumentType, null: false, description: 'The newly created document.'

        def resolve(file_name:, data:)
          authenticate!

          file = Shrine.data_uri(data, filename: file_name)
          document = current_user.documents.new(file:)
          authorize document, :create?

          if document.save
            { document: }
          else
            raise_model_validation_error!(document)
          end
        rescue Shrine::Plugins::DataUri::ParseError
          raise_simple_validation_error!(['Invalid file'])
        end
      end
    end
  end
end
