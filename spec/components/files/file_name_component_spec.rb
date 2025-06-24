# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Files::FileNameComponent do
  subject(:component) { described_class.new(user_file:) }

  let(:pdf_file) { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/sample.pdf')) }
  let(:user_file) { create(:user_file, attachment: pdf_file) }

  it 'renders file name' do
    render_inline(component)

    expect(page).to have_text('sample.pdf')
  end

  context "when file status is 'processing'" do
    before do
      user_file.update(status: 'processing')
    end

    it 'renders spinner' do
      render_inline(component)

      expect(page).to have_css('.fa-spinner')
    end
  end

  context "when file status is 'ready'" do
    before do
      user_file.update(status: 'ready')
    end

    it 'does not render spinner' do
      render_inline(component)

      expect(page).not_to have_css('.fa-spinner')
    end
  end

  context "when file status is 'failed'" do
    before do
      user_file.update(status: 'failed')
    end

    it 'does not render spinner' do
      render_inline(component)

      expect(page).not_to have_css('.fa-spinner')
    end
  end

  describe 'file type icon' do
    context 'when file is a document' do
      before do
        user_file.update(type: 'document')
      end

      it 'renders document icon' do
        render_inline(component)

        expect(page).to have_css('.fa-file-lines')
      end
    end

    context 'when file is an image' do
      before do
        user_file.update(type: 'image')
      end

      it 'renders image icon' do
        render_inline(component)

        expect(page).to have_css('.fa-file-image')
      end
    end

    context 'when file is unknown' do
      before do
        user_file.update(type: 'unknown')
      end

      it 'renders generic file icon' do
        render_inline(component)

        expect(page).to have_css('.fa-file')
      end
    end
  end
end
