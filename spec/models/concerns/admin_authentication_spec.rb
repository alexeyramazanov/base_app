# frozen_string_literal: true

require 'rails_helper'

# Not testing concern in isolation since it is just a logic extracted from the AdminUser model.
# This concern is not going to be used anywhere else.
RSpec.describe AdminAuthentication, type: :module do
  let(:password) { '123123' }
  let(:admin_user) do
    create(:admin_user, email: 'admin@email.com', password: password, password_confirmation: password)
  end

  describe 'validations' do
    context 'when record is new' do
      it 'validates presence of email, password and password_confirmation' do
        admin_user = AdminUser.new(email: '', password: '', password_confirmation: '')

        expected_errors = {
          email:                 [{ error: :blank }],
          password:              [{ error: :too_short, count: 6 }],
          password_confirmation: [{ error: :blank }]
        }
        expect(admin_user.valid?).to be(false)
        expect(admin_user.errors.details).to eq(expected_errors)
      end
    end

    context 'when record already exists' do
      it 'performs validations on password update attempt' do
        admin_user.update(password: '', password_confirmation: '', password_changed: true)

        expected_errors = {
          password:              [{ error: :too_short, count: 6 }],
          password_confirmation: [{ error: :blank }]
        }
        expect(admin_user.errors.details).to eq(expected_errors)
      end

      it 'validates password confirmation matches password' do
        admin_user.update(password: 'new_password', password_confirmation: 'different_password', password_changed: true)

        expected_errors = {
          password_confirmation: [{ error: :confirmation, attribute: 'Password' }]
        }
        expect(admin_user.errors.details).to include(expected_errors)
      end

      it 'skips password validations when password_changed is false' do
        result = admin_user.update(email: 'new_email@example.com')

        expect(result).to be(true)
        expect(admin_user.errors.details).to be_empty
      end
    end
  end

  it 'has associated sessions' do
    expect(admin_user.sessions.count).to eq(0)

    session = create(:admin_session, admin_user: admin_user)

    expect(admin_user.sessions).to match_array([session])
  end

  it 'implements password-based authentication' do
    expect(admin_user).to be_persisted
    expect(admin_user.password_digest).to be_present
    expect(admin_user.password_digest).not_to eq(password)
  end

  it 'normalizes email' do
    admin_user = AdminUser.create!(email: ' ADMIN@eMaIl.com  ', password: password, password_confirmation: password)

    expect(admin_user).to be_persisted
    expect(admin_user.email).to eq('admin@email.com')
  end

  describe '#authenticate_password' do
    it 'validates password' do
      expect(admin_user.authenticate_password('123123')).to eq(admin_user)
      expect(admin_user.authenticate_password('password')).to be(false)
    end
  end

  describe '.authenticate' do
    context 'when admin user does not exist' do
      it 'returns :not_found' do
        status, found_user = AdminUser.authenticate(email: 'some@email.com', password: password)

        expect(status).to eq(:not_found)
        expect(found_user).to be_nil
      end
    end

    context 'when password is invalid' do
      it 'returns :invalid_password' do
        status, found_user = AdminUser.authenticate(email: admin_user.email, password: 'some_password')

        expect(status).to eq(:invalid_password)
        expect(found_user).to be_nil
      end
    end

    context 'when password is correct' do
      it 'returns :success' do
        status, found_user = AdminUser.authenticate(email: admin_user.email, password: password)

        expect(status).to eq(:success)
        expect(found_user).to eq(admin_user)
      end
    end
  end
end
