# frozen_string_literal: true

module SharedUI
  module Dropdown
    class Component < ApplicationComponent
      attr_reader :items, :align

      renders_one :title

      def initialize(align: :left)
        super()

        @items = []
        @align = align
      end

      def item(url:, title: '', icon: '', data: {})
        @items << { url:, title:, icon:, data: }
      end

      def separator
        @items << { separator: true }
      end

      def align_class
        (align == :right) ? 'right-0' : ''
      end
    end
  end
end
