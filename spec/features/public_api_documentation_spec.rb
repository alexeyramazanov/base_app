# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Public API Documentation' do
  it 'renders Swagger UI' do
    visit public_api_swagger_path

    expect(page).to have_title('Public API Documentation')
    expect(page).to have_text('Operations about files')

    find('#operations-files-getV2Files').click
    expect(page).to have_text('List files')
  end
end
