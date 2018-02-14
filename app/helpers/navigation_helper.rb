module NavigationHelper
  def navigation_element(name, url, options = {})
    klass = current_page?(url) ? 'nav-item active' : 'nav-item'

    content_tag :li, class: klass do
      link_to name, url, {class: 'nav-link'}.merge(options)
    end
  end

  def dropdown_element(name, url, options = {})
    klass = current_page?(url) ? 'dropdown-item active' : 'dropdown-item'

    link_to name, url, {class: klass}.merge(options)
  end
end
