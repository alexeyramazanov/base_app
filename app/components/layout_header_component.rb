# frozen_string_literal: true

class LayoutHeaderComponent < ApplicationComponent
  renders_one :dropdown

  def initialize(logo_url:)
    super

    @logo_url = logo_url
  end
end
