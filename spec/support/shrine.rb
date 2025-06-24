# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:suite) do
    Shrine.storages.each_value do |storage|
      storage.clear! if storage.is_a?(Shrine::Storage::FileSystem)
    end
  end

  config.after(:suite) do
    Shrine.storages.each_value do |storage|
      storage.clear! if storage.is_a?(Shrine::Storage::FileSystem)
    end
  end
end
