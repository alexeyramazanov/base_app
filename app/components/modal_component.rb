# frozen_string_literal: true

class ModalComponent < ApplicationComponent
  attr_reader :title, :width_class

  renders_one :footer

  def initialize(title:, width_class: 'max-w-lg')
    super

    @title = title
    @width_class = width_class
  end
end
