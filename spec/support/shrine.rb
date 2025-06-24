# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:suite) do
    Shrine.storages.each_value do |storage|
      next unless storage.is_a?(Shrine::Storage::FileSystem)

      storage.clear!
    end
  end

  config.after(:suite) do
    Shrine.storages.each_value do |storage|
      next unless storage.is_a?(Shrine::Storage::FileSystem)

      storage.clear!
    end
  end
end
