# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShrineJobs::DestroyJob do
  subject(:job) { described_class.new.perform(attacher_class, data) }

  let(:attacher_class) { 'Shrine::Attacher' }
  let(:data) { { 'id' => 'file_123', 'storage' => 'store' } }
  let(:attacher) { instance_double(Shrine::Attacher) }

  before do
    allow(Shrine::Attacher).to receive(:from_data).with(data).and_return(attacher)
    allow(attacher).to receive(:destroy)
  end

  it 'destroys the attachment' do
    job

    expect(attacher).to have_received(:destroy)
  end
end
