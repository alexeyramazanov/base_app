# frozen_string_literal: true

class DropdownComponent < ApplicationComponent
  attr_reader :align

  renders_one :title

  def initialize(align: :left)
    super

    @align = align
  end

  def align_class
    align == :right ? 'right-0' : ''
  end
end
