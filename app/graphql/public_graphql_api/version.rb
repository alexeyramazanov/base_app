# frozen_string_literal: true

module PublicGraphqlApi
  class Version
    include GlobalID::Identification

    # required by GlobalID
    def self.find(_id)
      new
    end

    # GlobalID id
    def id
      1
    end

    def version
      '1.0.0'
    end

    def created_at
      Time.new(2025, 6, 10, 0, 0, 0, 'UTC')
    end

    def updated_at
      Time.new(2025, 6, 10, 0, 0, 0, 'UTC')
    end
  end
end
