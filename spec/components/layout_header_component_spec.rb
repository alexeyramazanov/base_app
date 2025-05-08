# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LayoutHeaderComponent do
  let(:logo_url) { 'https://example.com' }
  let(:content) { 'Home | About | Contact' }
  let(:dropdown) { 'Dropdown Content' }
  let(:component) do
    described_class.new(logo_url:).tap do |c|
      c.with_dropdown { dropdown }
    end
  end
  let(:rendered_component) { render_inline(component) { content } }

  before do
    rendered_component
  end

  it 'renders the component' do
    expect(page).to have_css('header.text-gray-600.body-font')
    expect(rendered_component).to have_css("a[href=\"#{logo_url}\"]")
    expect(page).to have_text(dropdown)
    expect(page).to have_text(content)
  end
end
