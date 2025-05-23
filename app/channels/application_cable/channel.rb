# frozen_string_literal: true

module ApplicationCable
  class Channel < ActionCable::Channel::Base
    private

    def html(partial, **locals)
      ApplicationController.render(partial:, locals:)
    end
  end
end
