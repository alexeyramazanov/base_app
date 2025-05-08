# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuthenticationHelper do
  describe '#authentication_status_error_message' do
    subject(:error_message) { helper.authentication_status_error_message(status) }

    context 'when status is :activation_required' do
      let(:status) { :activation_required }

      it 'returns message with activation link' do
        expected_message = 'You need to activate your account ' \
                           '<a href="/signup/request_activation_link" class="text-indigo-500">here</a> first.'
        expect(error_message).to eq(expected_message)
      end
    end

    context 'when status is not :activation_required' do
      let(:status) { :invalid }

      it 'returns invalid credentials message' do
        expect(error_message).to eq('Invalid email or password.')
      end
    end
  end
end
