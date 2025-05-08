# frozen_string_literal: true

class DropdownElementComponent < ApplicationComponent
  def initialize(url:, title: '', icon: '', data: {})
    super

    @title = title
    @url = url
    @icon = icon
    @data = data
  end
end
