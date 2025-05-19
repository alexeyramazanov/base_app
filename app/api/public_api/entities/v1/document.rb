# frozen_string_literal: true

module PublicApi
  module Entities
    module V1
      class Document < Grape::Entity
        expose :id
        expose :user_id
        expose :name

        private

        def name
          object.file.metadata['filename']
        end
      end
    end
  end
end
