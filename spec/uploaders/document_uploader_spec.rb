# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DocumentUploader do
  subject(:attacher) { described_class::Attacher.new }

  let(:jpg_file) do
    Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/sample.jpg'))
  end

  describe 'validations' do
    let(:pdf_file_with_invalid_ext) do
      Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/sample.pdf'), original_filename: 'sample.jpg')
    end
    let(:jpg_file_with_invalid_ext) do
      Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/sample.jpg'), original_filename: 'file.pdf')
    end

    it 'accepts valid image formats' do
      attacher.assign(jpg_file)
      attacher.validate

      expect(attacher.errors).to be_empty
    end

    it 'rejects invalid mime types' do
      attacher.assign(pdf_file_with_invalid_ext)
      attacher.validate

      expect(attacher.errors).to eq(['type must be one of: image/jpeg, image/png'])
    end

    it 'rejects invalid extensions' do
      attacher.assign(jpg_file_with_invalid_ext)
      attacher.validate

      expect(attacher.errors).to eq(['extension must be one of: jpg, jpeg, png'])
    end
  end

  describe 'derivatives' do
    it 'creates a thumbnail derivative' do
      expect(attacher.derivatives[:thumb]).to be_nil

      attacher.assign(jpg_file)
      attacher.create_derivatives

      expect(attacher.derivatives[:thumb].metadata['size']).not_to eq(attacher.file.metadata['size'])
    end
  end

  describe 'default_url' do
    it 'returns default file url when derivative is missing for some reason' do
      attacher.assign(jpg_file)

      derivative_url = attacher.url(:thumb)
      expect(derivative_url).to be_present
      expect(derivative_url).to eq(attacher.url)

      derivative_url = attacher.url(:not_existing_or_not_ready_derivative)
      expect(derivative_url).to be_present
      expect(derivative_url).to eq(attacher.url)

      attacher.create_derivatives

      derivative_url = attacher.url(:thumb)
      expect(derivative_url).to be_present
      expect(derivative_url).not_to eq(attacher.url)

      derivative_url = attacher.url(:not_existing_or_not_ready_derivative)
      expect(derivative_url).to be_present
      expect(derivative_url).to eq(attacher.url)
    end
  end
end
