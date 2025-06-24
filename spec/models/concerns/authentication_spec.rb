# frozen_string_literal: true

require 'rails_helper'

# Not testing concern in isolation since it is just a logic extracted from the User model.
# This concern is not going to be used anywhere else.
RSpec.describe Authentication, type: :module do
  include MailerHelpers

  let(:password) { '123123' }
  let(:user) do
    create(:user, email: 'user@email.com', password: password, password_confirmation: password,
           activation_state: 'active')
  end

  let(:auth_mailer_stub) { class_double(AuthenticationMailer) }

  describe 'validations' do
    context 'when record is new' do
      it 'validates presence of email, password and password_confirmation' do
        user = User.new(email: '', password: '', password_confirmation: '')

        expected_errors = {
          email:                 [{ error: :blank }],
          password:              [{ error: :too_short, count: 6 }],
          password_confirmation: [{ error: :blank }]
        }
        expect(user.valid?).to be(false)
        expect(user.errors.details).to eq(expected_errors)
      end
    end

    context 'when record already exists' do
      it 'performs validations on password update attempt' do
        user.update(password: '', password_confirmation: '', password_changed: true)

        expected_errors = {
          password:              [{ error: :too_short, count: 6 }],
          password_confirmation: [{ error: :blank }]
        }
        expect(user.errors.details).to eq(expected_errors)
      end

      it 'validates password confirmation matches password' do
        user.update(password: 'new_password', password_confirmation: 'different_password', password_changed: true)

        expected_errors = {
          password_confirmation: [{ error: :confirmation, attribute: 'Password' }]
        }
        expect(user.errors.details).to include(expected_errors)
      end

      it 'skips password validations when password_changed is false' do
        result = user.update(email: 'new_email@example.com')

        expect(result).to be(true)
        expect(user.errors.details).to be_empty
      end
    end

    it 'validates activation_state' do
      user.activation_state = nil

      expected_errors = {
        activation_state: [{ error: :inclusion, value: nil }]
      }
      expect(user.valid?).to be(false)
      expect(user.errors.details).to eq(expected_errors)
    end
  end

  it 'has associated sessions' do
    expect(user.sessions.count).to eq(0)

    session = create(:user_session, user: user)

    expect(user.sessions).to contain_exactly(session)
  end

  it 'implements password-based authentication' do
    expect(user).to be_persisted
    expect(user.password_digest).to be_present
    expect(user.password_digest).not_to eq(password)
    expect(user.activation_state).to eq('active')
  end

  it 'normalizes email' do
    user = User.create!(email: ' USER@eMaIl.com  ', password: password, password_confirmation: password)

    expect(user).to be_persisted
    expect(user.email).to eq('user@email.com')
  end

  describe '.authenticate' do
    context 'when user does not exist' do
      it 'returns :not_found' do
        status, found_user = User.authenticate(email: 'some@email.com', password: password)

        expect(status).to eq(:not_found)
        expect(found_user).to be_nil
      end
    end

    context 'when password is invalid' do
      it 'returns :invalid_password' do
        status, found_user = User.authenticate(email: user.email, password: 'some_password')

        expect(status).to eq(:invalid_password)
        expect(found_user).to be_nil
      end
    end

    context 'when user is present but account is not activated' do
      before do
        user.update_column(:activation_state, 'pending')
      end

      it 'returns :activation_required' do
        status, found_user = User.authenticate(email: user.email, password: '123123')

        expect(status).to eq(:activation_required)
        expect(found_user).to be_nil
      end
    end

    context 'when password is correct' do
      it 'returns :success' do
        status, found_user = User.authenticate(email: user.email, password: password)

        expect(status).to eq(:success)
        expect(found_user).to eq(user)
      end
    end
  end

  describe '.activate_account' do
    context 'when token is invalid' do
      before do
        user.update!(activation_state: 'pending', activation_token: 'abc',
                     activation_token_expires_at: Time.current + 1.day)
      end

      it 'does nothing' do
        expect(User.activate_account('token')).to be_nil

        user.reload
        expect(user.activation_state).to eq('pending')
      end
    end

    context 'when user is already activated' do
      before do
        user.update!(activation_state: 'active', activation_token: 'abc',
                     activation_token_expires_at: Time.current + 1.day)
      end

      it 'does nothing' do
        expect(User.activate_account('abc')).to be_nil

        user.reload
        expect(user.activation_state).to eq('active')
        expect(user.activation_token).to eq('abc')
      end
    end

    context 'when token has expired' do
      before do
        user.update!(activation_state: 'pending', activation_token: 'abc',
                     activation_token_expires_at: Time.current - 1.day)
      end

      it 'does nothing' do
        expect(User.activate_account('abc')).to be_nil

        user.reload
        expect(user.activation_state).to eq('pending')
      end
    end

    context 'when token is valid' do
      before do
        user.update!(activation_state: 'pending', activation_token: 'abc',
                     activation_token_expires_at: Time.current + 1.day)
      end

      it 'activates account and removes activation data' do
        expect(User.activate_account('abc')).to eq(user)

        user.reload
        expect(user.activation_state).to eq('active')
        expect(user.activation_token).to be_nil
        expect(user.activation_token_expires_at).to be_nil
      end
    end
  end

  describe '.find_by_reset_password_token' do
    context 'when token is invalid' do
      before do
        user.update!(reset_password_token: 'abc', reset_password_token_expires_at: Time.current + 1.day)
      end

      it 'returns nil' do
        expect(User.find_by_reset_password_token('token')).to be_nil # rubocop:disable Rails/DynamicFindBy
      end
    end

    context 'when token is expired' do
      before do
        user.update!(reset_password_token: 'abc', reset_password_token_expires_at: Time.current - 1.day)
      end

      it 'returns nil' do
        expect(User.find_by_reset_password_token('abc')).to be_nil # rubocop:disable Rails/DynamicFindBy
      end
    end

    context 'when token is valid' do
      before do
        user.update!(reset_password_token: 'abc', reset_password_token_expires_at: Time.current + 1.day)
      end

      it 'returns user' do
        expect(User.find_by_reset_password_token('abc')).to eq(user) # rubocop:disable Rails/DynamicFindBy
      end
    end
  end

  describe '#authenticate_password' do
    it 'validates password' do
      expect(user.authenticate_password('123123')).to eq(user)
      expect(user.authenticate_password('password')).to be(false)
    end
  end

  describe '#update_password' do
    let!(:original_digest) { user.password_digest }

    before do
      user.update!(reset_password_token: 'abc', reset_password_token_expires_at: Time.current + 1.day)
    end

    context 'when validations failed' do
      it 'returns false and does not change password' do
        expect(user.update_password(password: '123456', password_confirmation: '123123')).to be(false)

        user.reload
        expect(user.password_digest).to eq(original_digest)
      end
    end

    context 'when validations passed' do
      it 'returns user, changes password and clears reset_password data' do
        expect(user.update_password(password: '123456', password_confirmation: '123456')).to eq(user)

        user.reload
        expect(user.password_digest).not_to eq(original_digest)
        expect(user.reset_password_token).to be_nil
        expect(user.reset_password_token_expires_at).to be_nil
      end
    end
  end

  describe '#send_activation_link' do
    context 'when account is active' do
      it 'does not set activation_token and does not send an email' do
        user.send_activation_link

        user.reload
        expect(user.activation_token).to be_nil
        expect(user.activation_token_expires_at).to be_nil

        expect(enqueued_mailers.count).to eq(0)
      end
    end

    context 'when account is pending' do
      before do
        user.activation_state = 'pending'
      end

      it 'sets activation_token and sends an email' do
        user.send_activation_link

        mailer_job = enqueued_mailers.find do |job|
          job[:class] == 'AuthenticationMailer' && job[:action] == 'activation_link'
        end
        expect(mailer_job[:params]).to eq({ user_id: user.id })

        user.reload
        expect(user.activation_token).to be_present
        expect(user.activation_token_expires_at).to be_within(5.seconds).of(2.weeks.from_now)
      end
    end
  end

  describe '#send_password_reset_link' do
    context 'when account is pending' do
      before do
        user.activation_state = 'pending'
      end

      it 'triggers activation email instead of password reset' do
        allow(user).to receive(:send_activation_link)

        user.send_password_reset_link

        expect(user).to have_received(:send_activation_link)
      end
    end

    context 'when account is active' do
      it 'sets password_reset_token and sends an email' do
        user.send_password_reset_link

        mailer_job = enqueued_mailers.find do |job|
          job[:class] == 'AuthenticationMailer' && job[:action] == 'reset_password'
        end
        expect(mailer_job[:params]).to eq({ user_id: user.id })

        user.reload
        expect(user.reset_password_token).to be_present
        expect(user.reset_password_token_expires_at).to be_within(5.seconds).of(15.minutes.from_now)
      end
    end
  end
end
