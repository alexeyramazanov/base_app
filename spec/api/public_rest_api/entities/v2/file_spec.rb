# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PublicRestApi::Entities::V2::File do
  subject(:entity) { described_class.represent(user_file).as_json }

  let(:user_file) { create(:user_file) }

  it 'works and correctly exposes file_name and file_size' do
    expect(entity[:id]).to eq(user_file.id)
    expect(entity[:file_name]).to be_present
    expect(entity[:file_name]).to eq(user_file.attachment.original_filename)
    expect(entity[:file_size]).to be_present
    expect(entity[:file_size]).to eq(user_file.attachment.size)
  end
end
