# frozen_string_literal: true

class SharedUI::FlashMessages::Component < ApplicationComponent
  attr_reader :flash

  def initialize(flash:)
    super()

    @flash = flash
  end
end
