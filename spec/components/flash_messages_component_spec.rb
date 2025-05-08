# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FlashMessagesComponent do
  let(:flash) { {} }
  let(:component) { described_class.new(flash: flash) }
  let(:rendered_component) { render_inline(component) }

  context 'when flash has a notice' do
    let(:flash) { { notice: 'Success!' } }

    it 'renders the notice message' do
      expect(rendered_component).to have_css('div.border-l-4.border-green-400')
      expect(rendered_component).to have_text('Success!')
    end
  end

  context 'when flash has an alert' do
    let(:flash) { { alert: 'Error!' } }

    it 'renders the alert message' do
      expect(rendered_component).to have_css('div.border-l-4.border-red-400')
      expect(rendered_component).to have_text('Error!')
    end
  end

  context 'when flash is empty' do
    it 'does not render anything' do
      expect(rendered_component.inner_html.strip).to eq('')
    end
  end
end
