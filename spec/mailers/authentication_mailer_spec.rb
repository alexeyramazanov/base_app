# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuthenticationMailer do
  let(:user) { create(:user) }

  describe '#activation_link' do
    subject(:mail) { described_class.with(user_id: user.id).activation_link }

    before do
      user.update!(activation_token: 'test-activation-token')
    end

    it 'sends to the correct email' do
      expect(mail.to).to eq([user.email])
    end

    it 'has the correct subject' do
      expect(mail.subject).to eq('Activate your account')
    end

    it 'includes activation link in the email body' do
      expect(mail.body).to include(activate_signup_url('test-activation-token'))
    end
  end

  describe '#reset_password' do
    subject(:mail) { described_class.with(user_id: user.id).reset_password }

    before do
      user.update!(reset_password_token: 'test-reset-token')
    end

    it 'sends to the correct email' do
      expect(mail.to).to eq([user.email])
    end

    it 'has the correct subject' do
      expect(mail.subject).to eq('Reset password instructions')
    end

    it 'includes reset password link in the email body' do
      expect(mail.body).to include(new_password_password_reset_url('test-reset-token'))
    end
  end
end
