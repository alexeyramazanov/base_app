# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShrineJobs::DestroyJob do
  subject(:job) { described_class.new }

  let(:attachment) { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/sample.jpg').to_s) }

  let(:attacher_class) { 'UserFileUploader::Attacher' }

  context 'with promoted record' do
    let(:record) { create(:user_file, attachment: attachment) }
    let(:data) { record.attachment_data }

    before do
      # do not trigger any callbacks, just delete the record
      UserFile.where(id: record.id).delete_all
    end

    it 'removes file and all derivatives from storage' do
      original_file_path = record.attachment.storage.path(record.attachment.id)

      derivatives_path = record.attachment_derivatives.values.map do |derivative|
        derivative.storage.path(derivative.id)
      end
      expect(derivatives_path).not_to be_empty

      expect(File.exist?(original_file_path)).to be(true)
      derivatives_path.each do |path|
        expect(File.exist?(path)).to be(true)
      end

      job.perform(attacher_class, data)

      expect(File.exist?(original_file_path)).to be(false)
      derivatives_path.each do |path|
        expect(File.exist?(path)).to be(false)
      end
    end
  end

  context 'with not promoted record' do
    context 'with promoted record' do
      let(:record) { create(:user_file, attachment: attachment, skip_promotion: true) }
      let(:data) { record.attachment_data }

      before do
        # do not trigger any callbacks, just delete the record
        UserFile.where(id: record.id).delete_all
      end

      it 'removes file from storage' do
        expect(record.attachment_derivatives).to be_empty

        original_file_path = record.attachment.storage.path(record.attachment.id)

        expect(File.exist?(original_file_path)).to be(true)

        job.perform(attacher_class, data)

        expect(File.exist?(original_file_path)).to be(false)
      end
    end
  end
end
