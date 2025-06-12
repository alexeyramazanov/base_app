# frozen_string_literal: true

RSpec.shared_examples 'authenticated graphql endpoint' do
  let(:query) { raise ArgumentError }
  let(:variables) { {} }

  it 'denies access to the endpoint' do
    execute_graphql(query, nil, variables)

    expect(success?).to be(false)
    expect_data_in_empty
    expect_error_code('UNAUTHENTICATED')
    expect_error_message('Unauthenticated')
  end
end

RSpec.shared_examples 'authorized graphql endpoint' do
  let(:query) { raise ArgumentError }
  let(:user) { raise ArgumentError }
  let(:variables) { {} }

  it 'denies access to the resource' do
    execute_graphql(query, user, variables)

    expect(success?).to be(false)
    expect_data_in_empty
    expect_error_code('UNAUTHORIZED')
    expect_error_message('Unauthorized')
  end
end

RSpec.shared_examples 'graphql endpoint validating ID format' do
  let(:query) { raise ArgumentError }
  let(:user) { raise ArgumentError }
  let(:variables) { {} }

  it 'validates ID' do
    execute_graphql(query, user, variables)

    expect(success?).to be(false)
    expect_data_in_empty
    expect_error_code('VALIDATION_ERROR')
    expect_error_message('Validation Error')
  end
end

RSpec.shared_examples 'graphql endpoint returning NOT_FOUND error on invalid ID' do
  let(:query) { raise ArgumentError }
  let(:user) { raise ArgumentError }
  let(:variables) { {} }

  it 'returns NOT_FOUND error' do
    execute_graphql(query, user, variables)

    expect(success?).to be(false)
    expect_data_in_empty
    expect_error_code('NOT_FOUND')
    expect_error_message('Not Found')
  end
end
