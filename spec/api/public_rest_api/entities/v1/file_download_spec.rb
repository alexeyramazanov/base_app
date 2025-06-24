# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PublicRestApi::Entities::V1::FileDownload do
  subject(:entity) { described_class.represent(user_file).as_json }

  let(:user_file) { create(:user_file) }

  it 'works and correctly exposes url' do
    expect(entity[:id]).to eq(user_file.id)
    expect(entity[:url]).to include(user_file.attachment.id)
  end
end
