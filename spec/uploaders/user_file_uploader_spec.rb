# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserFileUploader do
  subject(:attacher) { described_class::Attacher.new }

  let(:jpg_file) do
    Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/sample.jpg'))
  end
  let(:pdf_file) do
    Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/sample.pdf'))
  end

  describe 'validations' do
    let(:invalid_file) do
      Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/logo_base64.txt'), original_filename: 'sample.jpg')
    end
    let(:jpg_file_with_invalid_ext) do
      Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/sample.jpg'), original_filename: 'file.txt')
    end

    it 'accepts valid image formats' do
      attacher.assign(jpg_file)
      attacher.validate

      expect(attacher.errors).to be_empty
    end

    it 'accepts valid document formats' do
      attacher.assign(pdf_file)
      attacher.validate

      expect(attacher.errors).to be_empty
    end

    it 'rejects invalid mime types' do
      attacher.assign(invalid_file)
      attacher.validate

      expect(attacher.errors).to eq(['type must be one of: image/jpg, image/jpeg, image/png, application/pdf'])
    end

    it 'rejects invalid extensions' do
      attacher.assign(jpg_file_with_invalid_ext)
      attacher.validate

      expect(attacher.errors).to eq(['extension must be one of: jpg, jpeg, png, pdf'])
    end
  end

  describe 'derivatives' do
    before do
      attacher.set_entity(record, :attachment)
    end

    context 'with images' do
      let(:record) { instance_double(UserFile, image?: true) }

      it 'creates a preview derivative' do
        expect(attacher.derivatives).to eq({})

        attacher.assign(jpg_file)
        attacher.create_derivatives

        expect(attacher.derivatives[:preview].metadata['size']).not_to eq(attacher.file.metadata['size'])
      end
    end

    context 'with documents' do
      let(:record) { instance_double(UserFile, image?: false) }

      it 'does not create a preview derivative' do
        expect(attacher.derivatives).to eq({})

        attacher.assign(pdf_file)
        attacher.create_derivatives

        expect(attacher.derivatives).to eq({})
      end
    end
  end

  describe 'default_url' do
    let(:record) { create(:user_file, skip_promotion: true) }

    it 'returns default file url when derivative is missing for some reason' do
      attacher.set_entity(record, :attachment)
      attacher.assign(jpg_file)

      derivative_url = attacher.url(:preview)
      expect(derivative_url).to be_present
      expect(derivative_url).to eq(attacher.url)

      derivative_url = attacher.url(:not_existing_or_not_ready_derivative)
      expect(derivative_url).to be_present
      expect(derivative_url).to eq(attacher.url)

      attacher.create_derivatives

      derivative_url = attacher.url(:preview)
      expect(derivative_url).to be_present
      expect(derivative_url).not_to eq(attacher.url)

      derivative_url = attacher.url(:not_existing_or_not_ready_derivative)
      expect(derivative_url).to be_present
      expect(derivative_url).to eq(attacher.url)
    end
  end

  describe 'promoter' do
    let(:record) { instance_double(UserFile, id: 14, image?: false) }

    it 'uses custom promoter' do
      attacher.set_entity(record, :attachment)
      attacher.assign(jpg_file)

      expect { attacher.finalize }
        .to enqueue_sidekiq_job(ShrineJobs::PromoteUserFileJob)
        .with(attacher.class.to_s, record.class.to_s, record.id, :attachment, anything)
    end
  end
end
