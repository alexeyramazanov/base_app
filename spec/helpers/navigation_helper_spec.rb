# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NavigationHelper do
  describe '#navigation_link' do
    subject(:nav_link) { helper.navigation_link(name, url, options:, link_options:) }

    let(:name) { 'Home' }
    let(:url) { '/home' }
    let(:options) { {} }
    let(:link_options) { {} }

    context 'when the current page matches exactly' do
      before do
        allow(helper).to receive(:current_page?).with(url).and_return(true)
      end

      it 'returns link with active class' do
        expect(nav_link).to eq('<a class="link mr-5 link-active" href="/home">Home</a>')
      end
    end

    context 'when using simple path matching' do
      let(:options) { { simple: true } }
      let(:request) { instance_double(ActionDispatch::Request, path: '/home/subpage') }

      before do
        allow(helper).to receive(:request).and_return(request)
      end

      it 'returns link with active class' do
        expect(nav_link).to eq('<a class="link mr-5 link-active" href="/home">Home</a>')
      end
    end

    context 'when the current page does not match' do
      before do
        allow(helper).to receive(:current_page?).with(url).and_return(false)
      end

      it 'returns link without active class' do
        expect(nav_link).to eq('<a class="link mr-5" href="/home">Home</a>')
      end
    end

    context 'with additional link options' do
      let(:link_options) { { data: { turbo: false } } }

      it 'merges additional options with default class' do
        expect(nav_link).to eq('<a class="link mr-5" data-turbo="false" href="/home">Home</a>')
      end
    end
  end
end
