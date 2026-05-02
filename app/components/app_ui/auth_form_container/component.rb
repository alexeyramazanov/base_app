# frozen_string_literal: true

module AppUI
  module AuthFormContainer
    class Component < ApplicationComponent
      attr_reader :title

      def initialize(title:)
        super()

        @title = title
      end
    end
  end
end
