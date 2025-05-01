# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShrineJobs::PromoteJob do
  subject(:job) { described_class.new.perform(attacher_class, record_class, record_id, name, file_data) }

  let(:record) { create(:document) }
  let(:uploader_attacher) { DocumentUploader::Attacher }

  let(:attacher_class) { DocumentUploader::Attacher.to_s }
  let(:record_class) { record.class.to_s }
  let(:record_id) { record.id }
  let(:name) { 'file' }
  let(:file_data) { { 'id' => 'image.jpg', 'storage' => 'cache' } }
  let(:attacher) { instance_double(uploader_attacher) }

  before do
    allow(uploader_attacher).to receive(:retrieve)
                                 .with(model: record, name: name, file: file_data)
                                 .and_return(attacher)
    allow(attacher).to receive(:create_derivatives)
    allow(attacher).to receive(:atomic_promote)
  end

  it 'processes and promotes the attachment' do
    job

    expect(attacher).to have_received(:create_derivatives)
    expect(attacher).to have_received(:atomic_promote)
  end

  context 'when record is not found' do
    before do
      record.destroy
    end

    it 'handles the error gracefully' do
      expect { job }.not_to raise_error
    end
  end

  context 'when attachment has changed' do
    before do
      allow(attacher).to receive(:create_derivatives).and_raise(Shrine::AttachmentChanged)
    end

    it 'handles the error gracefully' do
      expect { job }.not_to raise_error
    end
  end
end
