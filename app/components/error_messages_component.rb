# frozen_string_literal: true

class ErrorMessagesComponent < ApplicationComponent
  def initialize(model:)
    super

    @model = model
  end
end
