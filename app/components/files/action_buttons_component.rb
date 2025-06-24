# frozen_string_literal: true

module Files
  class ActionButtonsComponent < ViewComponent::Base
    def initialize(user_file:)
      super

      @user_file = user_file
    end

    private

    def icon_enabled_classes
      'fa-solid fa-fw fa-lg text-indigo-600 hover:text-gray-900 leading-none!'
    end

    def icon_disabled_classes
      'fa-solid fa-fw fa-lg text-indigo-600 opacity-50 leading-none!'
    end

    def preview_enabled_classes
      "#{icon_enabled_classes} fa-magnifying-glass"
    end

    def preview_disabled_classes
      "#{icon_disabled_classes} fa-magnifying-glass"
    end

    def download_enabled_classes
      "#{icon_enabled_classes} fa-download"
    end

    def download_disabled_classes
      "#{icon_disabled_classes} fa-download"
    end

    def delete_enabled_classes
      "#{icon_enabled_classes} fa-trash"
    end
  end
end
