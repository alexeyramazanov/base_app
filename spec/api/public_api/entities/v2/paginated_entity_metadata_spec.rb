# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PublicApi::Entities::V2::PaginatedEntityMetadata do
  subject(:entity) { described_class.represent(metadata).as_json }

  let(:metadata) { { current_page: 2, per_page: 10, total_pages: 2, total_count: 11 } }

  it 'works and correctly exposes metadata values' do
    expect(entity[:total_count]).to eq(11)
  end
end
