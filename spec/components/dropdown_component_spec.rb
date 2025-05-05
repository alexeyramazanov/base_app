# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DropdownComponent do
  let(:align) { :left }
  let(:title_content) { 'Dropdown Title' }
  let(:content) { 'Dropdown Content' }
  let(:component) do
    described_class.new(align:).tap do |c|
      c.with_title { title_content }
    end
  end
  let(:rendered_component) { render_inline(component) { content } }

  before do
    rendered_component
  end

  it 'renders the component' do
    expect(page).to have_css('div[data-controller="dropdown-component"]')
    expect(page).to have_text(title_content)
    expect(page).to have_text(content)
  end

  it 'aligns dropdown to the left by default' do
    expect(page).not_to have_css('div.right-0')
  end

  context 'when align is set to :right' do
    let(:align) { :right }

    it 'aligns dropdown to the right' do
      expect(page).to have_css('div.right-0')
    end
  end

  describe 'js functionality', type: :feature do
    it 'opens and closes the dropdown' do
      with_rendered_component_path(rendered_component, layout: 'public') do |path|
        visit(path)

        expect(page).not_to have_text(content)
        click_button title_content
        expect(page).to have_text(content)

        find('body').click # close dropdown
        expect(page).not_to have_text(content)
      end
    end
  end
end
