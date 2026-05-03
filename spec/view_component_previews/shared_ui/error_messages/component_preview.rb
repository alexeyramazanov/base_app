# frozen_string_literal: true

class SharedUI::ErrorMessages::ComponentPreview < Lookbook::Preview
  def default
    user = User.new
    user.valid?

    render SharedUI::ErrorMessages::Component.new(model: user)
  end
end
