# frozen_string_literal: true

module PublicApi
  module Helpers
    module PaginationHelpers
      include Pagy::Backend

      extend Grape::API::Helpers

      PER_PAGE = 10

      params :pagination do
        optional :page, type: Integer, default: 1, desc: 'Page number'
      end

      def paginate(collection)
        pagy, records = pagy(collection, page: params[:page], limit: PER_PAGE)

        {
          records:  records,
          metadata: {
            total_pages:  pagy.pages,
            total_count:  pagy.count,
            current_page: pagy.page,
            per_page:     pagy.limit
          }
        }
      end
    end
  end
end
