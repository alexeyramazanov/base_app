# frozen_string_literal: true

class FlashMessagesComponent < ApplicationComponent
  def initialize(flash:)
    super

    @flash = flash
  end
end
