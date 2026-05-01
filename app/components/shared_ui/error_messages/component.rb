# frozen_string_literal: true

module SharedUI
  module ErrorMessages
    class Component < ApplicationComponent
      attr_reader :model

      def initialize(model:)
        super()

        @model = model
      end
    end
  end
end
