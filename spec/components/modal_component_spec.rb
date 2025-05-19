# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ModalComponent do
  let(:title) { 'Test Modal' }
  let(:footer_content) { 'Footer Content' }
  let(:content) { 'Modal Content' }
  let(:component) do
    described_class.new(title:).tap do |c|
      c.with_footer { footer_content }
    end
  end
  let(:rendered_component) { render_inline(component) { content } }

  before do
    rendered_component
  end

  it 'renders the component' do
    expect(page).to have_css('div[data-controller="modal-component"]')
    expect(page).to have_text(title)
    expect(page).to have_text(content)
    expect(page).to have_text(footer_content)
    expect(page).to have_css("[data-action='click->modal-component#close']")
  end

  it 'uses lg width by default' do
    expect(page).to have_css('div.w-full.max-w-lg')
  end

  context 'when a custom width class is specified' do
    let(:width_class) { 'max-w-2xl' }
    let(:component) { described_class.new(title:, width_class:) }

    it 'uses specified width class' do
      expect(page).to have_css('div.w-full.max-w-2xl')
    end
  end

  describe 'js functionality', type: :feature do
    it 'removes modal when clicking on close button' do
      with_rendered_component_path(rendered_component, layout: 'public') do |path|
        visit(path)

        expect(page).to have_text(content)
        find('i.fa-xmark').click
        expect(page).not_to have_text(content)
      end
    end
  end
end
