# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Document do
  let(:file) { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/sample.jpg')) }

  describe 'concerns' do
    it 'includes DocumentUploader::Attachment' do
      expect(described_class.included_modules).to include(DocumentUploader::Attachment)
    end
  end

  describe 'validations' do
    let(:document) { build(:document) }

    it 'validates presence of file' do
      expect(document.valid?).to be(true)

      document.file = nil
      expect(document.valid?).to be(false)
      expect(document.errors.details[:file]).to include(error: :blank)

      document.file = file
      expect(document.valid?).to be(true)
    end
  end

  describe 'factories' do
    subject(:document) { build(:document) }

    it 'has a valid factory' do
      expect(document).to be_valid
    end
  end

  describe 'file attachment' do
    let(:document) { create(:document, file:) }

    it 'stores the file' do
      expect(document).to be_persisted
      expect(document.file).to be_present
      expect(document.file_url).to match_regex(%r{^/cache/.*\.jpg$})
    end

    it 'has correct metadata' do
      metadata = {
        'filename'  => 'sample.jpg',
        'mime_type' => 'image/jpeg',
        'size'      => 491
      }

      expect(document.file.metadata).to eq(metadata)
    end
  end
end
