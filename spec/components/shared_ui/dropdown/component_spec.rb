# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SharedUI::Dropdown::Component do
  let(:align) { :left }
  let(:title_content) { 'Dropdown Title' }
  let(:item) { { url: '/profile', title: 'Profile', icon: 'fa-solid fa-user' } }
  let(:component) do
    described_class.new(align:).tap do |c|
      c.with_title { title_content }
      c.item(**item)
    end
  end
  let(:rendered_component) { render_inline(component) }

  before do
    rendered_component
  end

  it 'renders the component' do
    expect(page).to have_css('div[data-controller="shared-ui--dropdown-component"]')
    expect(page).to have_text(title_content)
    expect(page).to have_text(item[:title])
  end

  it 'aligns dropdown to the left by default' do
    expect(page).to have_no_css('div.right-0')
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

        expect(page).to have_button(title_content)
        expect(page).to have_no_text(item[:title])
        click_button title_content
        expect(page).to have_text(item[:title])

        find('body').click # close dropdown
        expect(page).to have_no_text(item[:title])
      end
    end
  end
end
