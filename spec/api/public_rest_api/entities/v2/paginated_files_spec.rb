# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PublicRestApi::Entities::V2::PaginatedFiles do
  subject(:entity) { described_class.represent(object).as_json }

  let(:user_file1) { create(:user_file) }
  let(:user_file2) { create(:user_file) }
  let(:user_files) { [user_file1, user_file2] }
  let(:metadata) { { current_page: 2, per_page: 10, total_pages: 2, total_count: 11 } }
  let(:object) { { records: user_files, metadata: metadata } }

  it 'works and correctly exposes records and metadata' do
    expect(entity[:records].count).to eq(2)
    expect(entity[:records].map { |r| r[:id] }).to contain_exactly(user_file1.id, user_file2.id)
    expect(entity[:metadata][:current_page]).to eq(2)
  end
end
