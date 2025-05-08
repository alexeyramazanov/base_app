# frozen_string_literal: true

module NavigationHelper
  def navigation_link(name, url, options: {}, link_options: {})
    klass = 'link mr-5'

    current_page_matches = options[:simple] ? request.path.start_with?(url) : current_page?(url)
    klass += ' link-active' if current_page_matches

    link_to name, url, { class: klass }.merge(link_options)
  end
end
