# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PublicRestApi::Entities::V2::PaginatedEntity do
  subject(:entity) { described_class.represent(object).as_json }

  let(:record1) { { id: 5 } }
  let(:record2) { { id: 7 } }
  let(:records) { [record1, record2] }
  let(:metadata) { { current_page: 2, per_page: 10, total_pages: 2, total_count: 11 } }
  let(:object) { { records:, metadata: } }

  it 'works and correctly exposes records and metadata' do
    expect(entity[:records].count).to eq(2)
    expect(entity[:records].map { |r| r[:id] }).to contain_exactly(record1[:id], record2[:id])
    expect(entity[:metadata][:current_page]).to eq(2)
  end
end
