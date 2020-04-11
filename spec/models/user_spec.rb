require 'rails_helper'

RSpec.describe User, type: :model do
  let(:admin) { create(:admin) }

  it 'works' do
    expect(admin).to be_persisted
  end
end
