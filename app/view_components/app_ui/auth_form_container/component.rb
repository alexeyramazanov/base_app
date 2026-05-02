# frozen_string_literal: true

class AppUI::AuthFormContainer::Component < ApplicationComponent
  attr_reader :title

  def initialize(title:)
    super()

    @title = title
  end
end
