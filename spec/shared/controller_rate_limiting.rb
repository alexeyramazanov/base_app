# frozen_string_literal: true

RSpec.shared_examples 'page is rate limited' do
  let(:action) { raise ArgumentError }
  let(:max_requests) { raise ArgumentError }

  it 'redirects to dashboard' do
    max_requests.times do
      action.call

      expect(response).not_to redirect_to(too_many_requests_url)
    end

    action.call

    expect(response).to redirect_to(too_many_requests_url)
  end
end
