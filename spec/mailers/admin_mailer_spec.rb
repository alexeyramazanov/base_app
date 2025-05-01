# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminMailer do
  describe '#user_stats' do
    subject(:mail) { described_class.with(send_to_id: admin.id, users_count: users_count).user_stats }

    let(:admin) { create(:admin_user) }
    let(:users_count) { 42 }

    it 'sends to correct recipient' do
      expect(mail.to).to eq([admin.email])
    end

    it 'has correct subject' do
      expect(mail.subject).to eq('User statistics')
    end

    it 'includes user count in the body' do
      expect(mail.body).to include(users_count)
    end
  end
end
