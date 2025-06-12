# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PublicRestApi::Entities::V1::Error do
  subject(:entity) { described_class.represent(error).as_json }

  let(:error) do
    {
      code:    422,
      message: 'Validation failed',
      errors:  ['Name cannot be blank', 'Email is invalid']
    }
  end

  it 'works and correctly exposes attributes' do
    expect(entity[:code]).to eq(error[:code])
    expect(entity[:message]).to eq(error[:message])
    expect(entity[:errors]).to eq(error[:errors])
  end
end
