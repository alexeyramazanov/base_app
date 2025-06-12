# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PublicRestApi::Entities::V2::Document do
  subject(:entity) { described_class.represent(document).as_json }

  let(:document) { create(:document) }

  it 'works and correctly exposes file_name and file_size' do
    expect(entity[:id]).to eq(document.id)
    expect(entity[:file_name]).to be_present
    expect(entity[:file_name]).to eq(document.file.metadata['filename'])
    expect(entity[:file_size]).to be_present
    expect(entity[:file_size]).to eq(document.file.metadata['size'])
  end
end
