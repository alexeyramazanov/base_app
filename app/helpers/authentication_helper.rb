# frozen_string_literal: true

module AuthenticationHelper
  def authentication_status_error_message(status)
    case status
    when :activation_required
      link = tag.a('here', href: request_activation_link_signup_path, class: 'text-indigo-500')
      "You need to activate your account #{link} first.".html_safe # rubocop:disable Rails/OutputSafety
    else
      'Invalid email or password.'
    end
  end
end
