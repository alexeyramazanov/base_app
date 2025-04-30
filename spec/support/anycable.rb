# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:suite) do
    examples = RSpec.world.filtered_examples.values.flatten
    has_feature_tests = examples.any? { |example| example.metadata[:type] == :feature }

    # Start anycable only if feature specs are included
    next unless has_feature_tests

    require 'anycable/cli'

    command = [
      'ANYCABLE_DISABLE_TELEMETRY=true',
      'anycable-go',
      # '--debug',
      '--port 8123',
      '--rpc_host localhost:50051',
      '--rpc_concurrency 5',
      '--headers cookie,origin',
      '--broadcast_adapter redisx',
      '--broker memory',
      '--pubsub redis',
      '--enforce_jwt',
      '--turbo_streams'
    ].join(' ')

    AnyCable::CLI.embed!(["--server-command=#{command}"])
  end
end
