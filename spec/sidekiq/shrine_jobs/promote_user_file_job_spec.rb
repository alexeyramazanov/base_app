# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShrineJobs::PromoteUserFileJob do
  subject(:job) { described_class.new }

  let(:attachment) { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/sample.jpg').to_s) }
  let(:record) { create(:user_file, attachment: attachment, skip_promotion: true) }

  let(:attacher_class) { 'UserFileUploader::Attacher' }
  let(:record_class) { record.class.to_s }
  let(:record_id) { record.id }
  let(:name) { 'attachment' }
  let(:file_data) { record.attachment_data }

  it 'refreshes metadata' do
    file_data = record.attachment_data
    file_data['metadata'] = { 'filename' => 'sample.jpg' }
    record.update_column(:attachment_data, file_data)

    record.reload
    expect(record.attachment.metadata).to eq({ 'filename' => 'sample.jpg' })

    job.perform(attacher_class, record_class, record_id, name, file_data)

    record.reload
    expect(record.attachment.metadata).to eq({ 'filename' => 'sample.jpg', 'mime_type' => 'image/jpeg', 'size' => 491 })
  end

  it 'refreshes type' do
    record.update!(type: 'document')

    job.perform(attacher_class, record_class, record_id, name, file_data)

    record.reload
    expect(record.type).to eq('image')
  end

  it 'creates derivatives' do
    expect(record.attachment_derivatives).to eq({})

    job.perform(attacher_class, record_class, record_id, name, file_data)

    record.reload

    record.attachment_derivatives.values.map do |derivative|
      expect(File.exist?(derivative.storage.path(derivative.id))).to be(true)
    end
  end

  it 'promotes the attachment from cache to store' do
    expect(record.attachment.storage).to eq(Shrine.storages[:cache])

    job.perform(attacher_class, record_class, record_id, name, file_data)

    record.reload

    expect(record.attachment.storage).to eq(Shrine.storages[:store])
  end

  it 'marks record as ready' do
    expect(record.ready?).to be(false)

    job.perform(attacher_class, record_class, record_id, name, file_data)

    record.reload
    expect(record.ready?).to be(true)
  end

  context 'when file type is unknown' do
    let(:fake_attachment) do
      file = Tempfile.new(%w[fake_image .png]).tap do |file|
        file.write('hello world')
      end

      Rack::Test::UploadedFile.new(file.path)
    end
    let(:record) do
      r = build(:user_file, attachment: fake_attachment, skip_promotion: true)
      r.attachment_data['metadata']['mime_type'] = 'image/png'
      r.save!(validate: false)
      r.reload
      r
    end

    it 'marks record as failed' do
      expect(record.attachment.mime_type).to eq('image/png')

      job.perform(attacher_class, record_class, record_id, name, file_data)

      record.reload
      expect(record.failed?).to be(true)
      expect(record.attachment.mime_type).to be_nil
    end
  end

  context 'when record is not found' do
    before do
      record.destroy
    end

    it 'handles the error gracefully' do
      expect { job.perform(attacher_class, record_class, record_id, name, file_data) }.not_to raise_error
    end
  end

  context 'when attachment has changed' do
    let(:file_data) do
      fd = super()
      fd['id'] = 'other_file.jpg' # now metadata does not match one stored in DB
      fd
    end

    it 'handles the error gracefully' do
      expect { job.perform(attacher_class, record_class, record_id, name, file_data) }.not_to raise_error
    end
  end
end
