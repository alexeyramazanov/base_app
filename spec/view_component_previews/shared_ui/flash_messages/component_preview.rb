# frozen_string_literal: true

class SharedUI::FlashMessages::ComponentPreview < Lookbook::Preview
  def notice
    render SharedUI::FlashMessages::Component.new(flash: { notice: 'Your changes have been saved successfully.' })
  end

  def alert
    render SharedUI::FlashMessages::Component.new(flash: { alert: 'Something went wrong. Please try again.' })
  end

  def both
    render SharedUI::FlashMessages::Component.new(
      flash: {
        notice: 'Your changes have been saved successfully.',
        alert:  'Something went wrong. Please try again.'
      }
    )
  end
end
