# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DropdownElementComponent do
  let(:url) { '/test-url' }
  let(:title) { 'Test Title' }
  let(:icon) { 'fa-test' }
  let(:data) { { test: 'value' } }
  let(:component) { described_class.new(url: url, title: title, icon: icon, data: data) }
  let(:rendered_component) { render_inline(component) }

  before do
    rendered_component
  end

  it 'renders the link with correct attributes' do
    expect(page).to have_link(title, href: url)
    expect(page).to have_css("i.#{icon}")
    expect(page).to have_css("a[data-test='value']")
  end

  context 'with special :separator url value' do
    let(:url) { :separator }

    it 'renders a separator div instead of a link' do
      expect(page).not_to have_css('a')
      expect(page).to have_css('div.h-px.bg-gray-200.my-1')
    end
  end
end
