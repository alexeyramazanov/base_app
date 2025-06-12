# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PublicRestApi::Entities::V2::PaginatedDocuments do
  subject(:entity) { described_class.represent(object).as_json }

  let(:document1) { create(:document) }
  let(:document2) { create(:document) }
  let(:documents) { [document1, document2] }
  let(:metadata) { { current_page: 2, per_page: 10, total_pages: 2, total_count: 11 } }
  let(:object) { { records: documents, metadata: metadata } }

  it 'works and correctly exposes records and metadata' do
    expect(entity[:records].count).to eq(2)
    expect(entity[:records].map { |r| r[:id] }).to contain_exactly(document1.id, document2.id)
    expect(entity[:metadata][:current_page]).to eq(2)
  end
end
