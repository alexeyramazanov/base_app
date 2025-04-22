# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self, :https
    policy.font_src    :self, :https, :data
    policy.img_src     :self, :https, :data
    policy.object_src  :none
    policy.script_src  :self, :https
    policy.style_src   :self, :https
    policy.connect_src :self

    if ENV.fetch('ANYCABLE_WEBSOCKET_URL', nil).present?
      policy.connect_src(*policy.connect_src, ENV.fetch('ANYCABLE_WEBSOCKET_URL'))
    end
    if ENV.fetch('AWS_ENDPOINT', nil).present?
      policy.connect_src(*policy.connect_src, ENV.fetch('AWS_ENDPOINT'))
      policy.img_src(*policy.img_src, ENV.fetch('AWS_ENDPOINT'))
    end

    case Rails.env
    when 'production'
      # turbo progressbar - https://github.com/hotwired/turbo/issues/809
      policy.style_src(*policy.style_src, "'sha256-WAyOw4V+FqDc35lQPyRADLBWbuNK8ahvYEaQIYF1+Ps='")
    else
      # Allow @vite/client to hot reload changes in development
      # Allow to access resources from http
      # Allow embedding of inline js/css for turbo and other libs
      policy.img_src(*policy.img_src, :http)
      policy.connect_src(*policy.connect_src, "ws://#{ViteRuby.config.host_with_port}")
      policy.script_src(*policy.script_src, :unsafe_eval, :unsafe_inline, "http://#{ViteRuby.config.host_with_port}")
      policy.style_src(*policy.style_src, :unsafe_inline)
    end

    # You may need to enable this in production as well depending on your setup.
    policy.script_src(*policy.script_src, :blob) if Rails.env.test?

    # Specify URI for violation reports
    # policy.report_uri "/csp-violation-report-endpoint"
  end

  # Generate session nonces for permitted importmap, inline scripts, and inline styles.
  # config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  # config.content_security_policy_nonce_directives = %w(script-src style-src)

  # Report violations without enforcing the policy.
  # config.content_security_policy_report_only = true
end
