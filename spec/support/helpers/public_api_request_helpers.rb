# frozen_string_literal: true

module PublicApiRequestHelpers
  def make_api_request(method, path, token = nil, params: {}, headers: {})
    headers = { 'Authorization' => "Bearer #{token}" }.reverse_merge(headers) if token

    send(method, path, params:, headers:)

    # if %i[patch post put].include?(method)
    #   send(method, path, params: params, headers: headers, as: :json)
    # else
    #   send(method, path, params:, headers:)
    # end
  end
end

RSpec.configure do |config|
  config.include PublicApiRequestHelpers, type: :request
end
