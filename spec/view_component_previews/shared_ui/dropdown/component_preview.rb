# frozen_string_literal: true

class SharedUI::Dropdown::ComponentPreview < Lookbook::Preview
  def default
    render SharedUI::Dropdown::Component.new do |dd_component|
      dd_component.with_title do
        'Mike Smith'
      end

      dd_component.item(url: '#', title: 'Profile', icon: 'fa-solid fa-user')
      dd_component.separator
      dd_component.item(url: '#', title: 'Sign out', icon: 'fa-solid fa-right-from-bracket',
                        data: { turbo_method: :delete })
    end
  end
end
