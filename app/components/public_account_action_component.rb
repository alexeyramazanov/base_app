# frozen_string_literal: true

class PublicAccountActionComponent < ApplicationComponent
  def initialize(title:)
    super

    @title = title
  end
end
