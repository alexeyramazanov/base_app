# frozen_string_literal: true

RSpec.shared_examples 'page does not allow user access' do
  let(:user_session) { create(:user_session) }
  let(:action) { raise ArgumentError }

  before do
    cookies.signed[:session_id] = user_session.id
    cookies.signed[:admin_session_id] = nil
  end

  it 'redirects to dashboard' do
    action

    expect(response).to redirect_to(dashboard_url)
  end
end

RSpec.shared_examples 'page does not allow admin access' do
  let(:admin_session) { create(:admin_session) }
  let(:action) { raise ArgumentError }

  before do
    cookies.signed[:session_id] = nil
    cookies.signed[:admin_session_id] = admin_session.id
  end

  it 'redirects to dashboard' do
    action

    expect(response).to redirect_to(admin_dashboard_url)
  end
end

RSpec.shared_examples 'page does not allow unauthenticated access' do
  let(:action) { raise ArgumentError }
  let(:redirect_url) { sign_in_url }

  before do
    cookies.signed[:session_id] = nil
    cookies.signed[:admin_session_id] = nil
  end

  it 'redirects to sign in page' do
    action

    expect(response).to redirect_to(redirect_url)
  end
end
