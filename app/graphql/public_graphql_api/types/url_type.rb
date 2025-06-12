# frozen_string_literal: true

module PublicGraphqlApi
  module Types
    class UrlType < Types::BaseScalar
      description 'A valid URL, transported as a string'

      def self.coerce_input(val, _ctx)
        url = URI.parse(val)

        unless url.is_a?(URI::HTTP) || url.is_a?(URI::HTTPS)
          raise GraphQL::CoercionError, "#{val.inspect} is not a valid URL"
        end

        url
      end

      def self.coerce_result(val, _ctx)
        val.to_s
      end
    end
  end
end
