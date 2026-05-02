# frozen_string_literal: true

class SharedUI::ErrorMessages::Component < ApplicationComponent
  attr_reader :model

  def initialize(model:)
    super()

    @model = model
  end
end
