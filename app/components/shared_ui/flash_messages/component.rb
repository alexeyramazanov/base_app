# frozen_string_literal: true

module SharedUI
  module FlashMessages
    class Component < ApplicationComponent
      attr_reader :flash

      def initialize(flash:)
        super()

        @flash = flash
      end
    end
  end
end
