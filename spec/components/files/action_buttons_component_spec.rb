# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Files::ActionButtonsComponent do
  include Rails.application.routes.url_helpers

  subject(:component) { described_class.new(user_file:) }

  let(:image_file) { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/sample.jpg')) }
  let(:pdf_file) { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/sample.pdf')) }

  before do
    render_inline(component)
  end

  shared_examples 'a disabled button' do |text|
    it 'renders a disabled button with a tooltip' do
      expect(page).to have_css("i[data-controller='shared--tooltip'][data-shared--tooltip-content-value='#{text}']")
    end
  end

  describe 'preview button' do
    context 'when file is processing' do
      let(:user_file) { create(:user_file, skip_promotion: true) }

      it_behaves_like 'a disabled button', 'Preview is not available while file is being processed'
    end

    context 'when file is ready' do
      context 'when file is an image' do
        let(:user_file) { create(:user_file, attachment: image_file) }

        it 'renders a preview link' do
          expect(page).to have_link(href: preview_file_path(user_file))
        end
      end

      context 'when file is not an image' do
        let(:user_file) { create(:user_file, attachment: pdf_file) }

        it_behaves_like 'a disabled button', 'Preview is not available for non-image files'
      end
    end

    context 'when file has other status' do
      let(:user_file) do
        create(:user_file, skip_promotion: true).tap(&:failed!)
      end

      it_behaves_like 'a disabled button', 'Unsupported file'
    end
  end

  describe 'download button' do
    context 'when file is processing' do
      let(:user_file) { create(:user_file, skip_promotion: true) }

      it_behaves_like 'a disabled button', 'Download is not available while file is being processed'
    end

    context 'when file is ready' do
      context 'when file is not unknown' do
        let(:user_file) { create(:user_file, attachment: image_file) }

        it 'renders a download link' do
          expect(page).to have_link(href: download_file_path(user_file))
        end
      end

      context 'when file is unknown' do
        let(:user_file) do
          uf = create(:user_file)
          uf.update_column(:type, 'unknown')
          uf
        end

        it_behaves_like 'a disabled button', 'Downloading unknown files is not supported'
      end
    end

    context 'when file has other status' do
      let(:user_file) do
        create(:user_file, skip_promotion: true).tap(&:failed!)
      end

      it_behaves_like 'a disabled button', 'Unsupported file'
    end
  end

  describe 'delete button' do
    let(:user_file) { create(:user_file) }

    it 'renders a delete link' do
      expect(page).to have_css("a[href='#{file_path(user_file)}'][data-turbo-method='delete']")
    end
  end
end
