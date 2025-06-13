# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ErrorMessagesComponent do
  let(:model_definition) do
    Class.new do
      include ActiveModel::API

      attr_accessor :name

      validates :name, presence: true

      def self.model_name
        ActiveModel::Name.new(self, nil, 'ErrorMessagesComponentModel')
      end
    end
  end
  let(:model) { model_definition.new }
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
    let(:model) { model_definition.new(name: 'John') }

    it 'does not render anything' do
      expect(rendered_component.inner_html).to eq('')
    end
  end
end
