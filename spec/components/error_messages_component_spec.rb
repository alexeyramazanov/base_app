# frozen_string_literal: true

require 'rails_helper'

class ErrorMessagesComponentModel
  include ActiveModel::API

  attr_accessor :name

  validates :name, presence: true
end

RSpec.describe ErrorMessagesComponent do
  let(:model) { ErrorMessagesComponentModel.new }
  let(:component) { described_class.new(model: model) }
  let(:rendered_component) { render_inline(component) }

  before do
    model.validate
    rendered_component
  end

  it 'renders the component' do
    expect(rendered_component).to have_css('div.border-l-4.border-red-400')
    expect(rendered_component).to have_text("Name can't be blank")
  end

  context 'when model has no errors' do
    let(:model) { ErrorMessagesComponentModel.new(name: 'John') }

    it 'does not render anything' do
      expect(rendered_component.inner_html).to eq('')
    end
  end
end
