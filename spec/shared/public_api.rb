# frozen_string_literal: true

RSpec.shared_examples 'authenticated_endpoint' do
  let(:request_method) { :get }
  let(:path) { raise ArgumentError }
  let(:params) { {} }

  it 'requires authentication' do
    make_api_request(request_method, path, nil, params:)

    expect(response).to have_http_status(:unauthorized)
  end
end

RSpec.shared_examples 'paginated_endpoint' do
  let(:request_method) { :get }
  let(:path) { raise ArgumentError }
  let(:token) { raise ArgumentError }
  let(:params) { {} }

  it 'returns pagination metadata' do
    make_api_request(request_method, path, token, params:)

    expect(response).to have_http_status(:ok)

    data = JSON.parse(response.body)
    expect(data.key?('metadata')).to be(true)
    expect(data['metadata'].keys).to match_array(%w[current_page per_page total_pages total_count])
  end

  it 'accepts pagination params' do
    make_api_request(request_method, path, token, params: params.merge(page: 1))

    expect(response).to have_http_status(:ok)

    data = JSON.parse(response.body)
    expect(data.key?('metadata')).to be(true)
  end
end
