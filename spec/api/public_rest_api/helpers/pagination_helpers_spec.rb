# frozen_string_literal: true

require 'rails_helper'

class PublicApiTestPaginationHelpersEndpoints < Grape::API
  helpers PublicRestApi::Helpers::PaginationHelpers

  namespace :test do
    params do
      use :pagination
    end
    get :paginate_users do
      authorize :dashboard, :show?

      paginated_data = paginate(User.order(id: :desc))

      present paginated_data, with: PublicRestApi::Entities::V2::PaginatedEntity
    end
  end
end

module PublicRestApi
  class Root
    mount PublicApiTestPaginationHelpersEndpoints
  end
end

RSpec.describe PublicRestApi::Helpers::PaginationHelpers do
  describe 'paginate' do
    let(:user) { create(:user) }
    let(:api_token) { create(:api_token, user:) }

    before do
      user
      create_list(:user, 10)
    end

    it 'returns correctly paginated results with metadata' do
      make_api_request :get, '/public_api/test/paginate_users', api_token.token, params: { page: 2 }

      expect(response).to have_http_status(:ok)

      data = JSON.parse(response.body)
      expect(data['metadata']).to eq({ 'current_page' => 2, 'per_page' => 10, 'total_pages' => 2, 'total_count' => 11 })
      expect(data['records'].count).to eq(1)
      expect(data['records'][0]['email']).to eq(user.email)
    end
  end
end
