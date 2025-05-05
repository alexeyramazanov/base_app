# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PublicAccountActionComponent do
  let(:title) { 'Account Action Title' }
  let(:content) { 'Account Action Content' }
  let(:component) { described_class.new(title:) }
  let(:rendered_component) { render_inline(component) { content } }

  before do
    rendered_component
  end

  it 'renders the component' do
    expect(page).to have_css('section.container', text: content)
    expect(page).to have_css('h2', text: title)
    expect(page).to have_text(content)
  end
end
