# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::UserStatsJob do
  subject(:job) { described_class.new.perform(admin_user.id) }

  let(:admin_user) { create(:admin_user) }

  let(:user_stats_mailer_stub) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }
  let(:mailer_stub) { class_double(AdminMailer, user_stats: user_stats_mailer_stub) }

  before do
    create_list(:user, 3)

    allow(AdminMailer).to receive(:with).with(send_to_id: admin_user.id, users_count: 3).and_return(mailer_stub)
  end

  it 'sends stats email' do
    job

    expect(user_stats_mailer_stub).to have_received(:deliver_later)
  end
end
