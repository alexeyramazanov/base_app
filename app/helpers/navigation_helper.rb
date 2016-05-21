module NavigationHelper
  def navigation_element(name, url, options = {})
    klass = current_page?(url) ? 'active' : ''

    content_tag :li, class: klass do
      link_to name, url, options
    end
  end
end
