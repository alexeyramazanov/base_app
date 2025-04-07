# frozen_string_literal: true

module NavigationHelper
  def navigation_link(name, url, options = {})
    klass = 'mr-5 hover:text-gray-900'
    klass += ' text-indigo-600' if current_page?(url)

    link_to name, url, { class: klass }.merge(options)
  end
end
