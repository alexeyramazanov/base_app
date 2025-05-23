# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PublicApi::Entities::V1::DocumentDownload do
  subject(:entity) { described_class.represent(document).as_json }

  let(:document) { create(:document) }

  it 'works and correctly exposes url' do
    expect(entity[:id]).to eq(document.id)
    expect(entity[:url]).to include(document.file.id)
  end
end
