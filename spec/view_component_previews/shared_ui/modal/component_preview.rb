# frozen_string_literal: true

class SharedUI::Modal::ComponentPreview < Lookbook::Preview
  def default
    render SharedUI::Modal::Component.new(title: 'Confirm Action') do |modal|
      modal.with_footer do
        content_tag(:button, 'Cancel', class: 'px-4 py-2 bg-gray-200 rounded cursor-pointer',
                                       data:  { action: 'click->shared-ui--modal-component#close' }) +
          content_tag(:button, 'Confirm', class: 'px-4 py-2 bg-blue-600 text-white rounded cursor-pointer')
      end

      'Are you sure you want to proceed with this action?'
    end
  end
end
