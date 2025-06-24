# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/RepeatedExample, RSpec/RepeatedDescription, Rails/SkipsModelValidations
RSpec.describe UserFilePolicy do
  subject(:policy) { described_class }

  let(:user) { create(:user) }

  let(:own_user_file) { create(:user_file, user:) }
  let(:other_user_file) { create(:user_file) }

  permissions '.scope' do
    let(:scope) { described_class::Scope.new(user, UserFile.all).resolve }

    before do
      own_user_file
      other_user_file
    end

    it 'scopes to only user files' do
      expect(scope).to contain_exactly(own_user_file)
    end
  end

  permissions :index?, :s3_params? do
    it 'grants access' do
      expect(policy).to permit(user, nil)
    end
  end

  permissions :show?, :new?, :create?, :edit?, :update?, :destroy? do
    it 'grants access to own file' do
      expect(policy).to permit(user, own_user_file)
    end

    it 'denies access to other user file' do
      expect(policy).not_to permit(user, other_user_file)
    end
  end

  permissions :preview?, :download? do
    let(:own_pending_file) do
      uf = create(:user_file, user:)
      uf.update_column(:status, 'pending')
      uf
    end
    let(:own_failed_file) do
      uf = create(:user_file, user:)
      uf.update_column(:status, 'failed')
      uf
    end

    it 'grants access to own processed file' do
      expect(policy).to permit(user, own_user_file)
    end

    it 'denies access to own pending file' do
      expect(policy).not_to permit(user, own_pending_file)
    end

    it 'denies access to own failed file' do
      expect(policy).not_to permit(user, own_failed_file)
    end

    it 'denies access to other user file' do
      expect(policy).not_to permit(user, other_user_file)
    end
  end
end
# rubocop:enable RSpec/RepeatedExample, RSpec/RepeatedDescription, Rails/SkipsModelValidations
