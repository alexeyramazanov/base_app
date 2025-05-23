# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiToken do
  describe 'callbacks' do
    let(:api_token) { build(:api_token) }

    it 'generates a token before create' do
      expect(api_token.token).to be_nil

      api_token.save
      expect(api_token.token).not_to be_nil
      expect(api_token.token.length).to eq(32)
    end
  end

  describe 'factories' do
    it 'has a valid factory' do
      api_token = create(:api_token)

      expect(api_token).to be_persisted
    end
  end

  describe '#generate_token' do
    subject(:api_token) { build(:api_token) }

    it 'generates a 32 character alphanumeric token' do
      expect(api_token.token).to be_nil

      api_token.send(:generate_token)

      expect(api_token.token).to be_present
      expect(api_token.token.length).to eq(32)
      expect(api_token.token).to match(/^[a-zA-Z0-9]+$/)
    end
  end

  describe '#used_now!' do
    let(:api_token) { create(:api_token) }

    it 'sets last_used_at value to current time' do
      expect(api_token.last_used_at).to be_nil

      api_token.used_now!

      api_token.reload
      expect(api_token.last_used_at).to be_within(2.seconds).of(Time.current)
    end
  end
end
