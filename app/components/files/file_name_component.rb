# frozen_string_literal: true

module Files
  class FileNameComponent < ViewComponent::Base
    def initialize(user_file:)
      super

      @user_file = user_file
    end

    private

    def type_icon
      case @user_file.type
      when 'image'
        'fa-file-image'
      when 'document'
        'fa-file-lines'
      else
        'fa-file'
      end
    end
  end
end
