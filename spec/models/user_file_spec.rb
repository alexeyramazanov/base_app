# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserFile do
  let(:file) { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/sample.jpg')) }

  shared_examples 'event triggering turbo stream for updating user files table' do
    let(:user_file) { raise ArgumentError }
    let(:action) { raise ArgumentError }

    it 'broadcasts to user user_files stream' do
      target_id = ActionView::RecordIdentifier.dom_id(user_file)

      expect { action.call }
        .to have_broadcasted_to([user_file.user.to_gid_param, 'user_files'].join(':'))
        .with(a_string_including("<turbo-stream action=\"replace\" target=\"#{target_id}\">"))
    end
  end

  describe 'concerns' do
    it 'includes UserFileUploader::Attachment' do
      expect(described_class.included_modules).to include(UserFileUploader::Attachment)
    end
  end

  describe 'validations' do
    let(:user_file) { build(:user_file) }

    it 'validates presence of file' do
      expect(user_file.valid?).to be(true)

      user_file.attachment = nil
      expect(user_file.valid?).to be(false)
      expect(user_file.errors.details[:attachment]).to include(error: :blank)

      user_file.attachment = file
      expect(user_file.valid?).to be(true)
    end

    it 'validates presence of type' do
      expect(user_file.valid?).to be(true)

      user_file.type = nil
      expect(user_file.valid?).to be(false)
      expect(user_file.errors.details[:type]).to include(error: :inclusion, value: nil)
    end
  end

  describe 'on create' do
    it 'sets proper file type' do
      user_file = build(:user_file, attachment: file)

      expect(user_file.type).to eq('unknown')

      user_file.save!

      expect(user_file.type).to eq('image')
    end
  end

  describe 'factories' do
    it 'has a valid factory' do
      user_file = build(:user_file)

      expect(user_file).to be_valid
    end

    it 'runs promotion job' do
      user_file = create(:user_file)

      expect(user_file).to be_ready
    end

    context 'when promotion is skipped' do
      it 'does not run promotion job' do
        user_file = create(:user_file, skip_promotion: true)

        expect(user_file).to be_processing
      end
    end
  end

  describe 'attachment' do
    let(:user_file) { create(:user_file, attachment: file) }

    it 'stores the file' do
      expect(user_file).to be_persisted
      expect(user_file.attachment).to be_present
      expect(user_file.attachment_url).to match_regex(%r{^/uploads/test/store/.*\.jpg$})
    end

    it 'has correct metadata' do
      metadata = {
        'filename'  => 'sample.jpg',
        'mime_type' => 'image/jpeg',
        'size'      => 491
      }

      expect(user_file.attachment.metadata).to eq(metadata)
    end
  end

  describe 'status state machine' do
    let(:user_file) { create(:user_file, skip_promotion: true) }

    it 'supports transitions' do
      expect(user_file).to transition_from(:processing).to(:ready).on_event(:ready)
      expect(user_file).to transition_from(:processing).to(:failed).on_event(:failed)
    end

    describe "'ready' event" do
      it_behaves_like 'event triggering turbo stream for updating user files table' do
        let(:user_file) { super() }
        let(:action) { -> { user_file.ready! } }
      end
    end

    describe "'failed' event" do
      it_behaves_like 'event triggering turbo stream for updating user files table' do
        let(:user_file) { super() }
        let(:action) { -> { user_file.failed! } }
      end
    end
  end

  describe '#refresh_type!' do
    let(:user_file) do
      uf = create(:user_file)
      uf.update_column(:type, 'unknown')
      uf
    end

    it 'updates file type' do
      expect(user_file.type).to eq('unknown')

      user_file.refresh_type!

      user_file.reload
      expect(user_file.type).to eq('image')
    end
  end

  describe '#detect_type' do
    let(:user_file) { create(:user_file) }

    context 'when file MIME type is an image' do
      before do
        allow(user_file.attachment).to receive(:mime_type).and_return('image/jpeg')
      end

      it "returns 'image'" do
        expect(user_file.send(:detect_type)).to eq('image')
      end
    end

    context 'when file MIME type is a document' do
      before do
        allow(user_file.attachment).to receive(:mime_type).and_return('application/pdf')
      end

      it "returns 'document'" do
        expect(user_file.send(:detect_type)).to eq('document')
      end
    end

    context 'when file MIME type is something else' do
      before do
        allow(user_file.attachment).to receive(:mime_type).and_return('application/mp4')
      end

      it "returns 'unknown'" do
        expect(user_file.send(:detect_type)).to eq('unknown')
      end
    end
  end
end
