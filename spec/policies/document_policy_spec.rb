# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DocumentPolicy do
  subject(:policy) { described_class }

  let(:user) { create(:user) }

  let(:own_document) { create(:document, user:) }
  let(:other_user_document) { create(:document) }

  permissions '.scope' do
    let(:scope) { described_class::Scope.new(user, Document.all).resolve }

    before do
      own_document
      other_user_document
    end

    it 'scopes to only user documents' do
      expect(scope).to contain_exactly(own_document)
    end
  end

  permissions :index?, :s3_params? do
    it 'grants access' do
      expect(policy).to permit(user, nil)
    end
  end

  permissions :show?, :new?, :create?, :edit?, :update?, :destroy?, :download? do
    it 'grants access to own document' do
      expect(policy).to permit(user, own_document)
    end

    it 'denies access to other user document' do
      expect(policy).not_to permit(user, other_user_document)
    end
  end
end
