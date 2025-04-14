# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    # lazily evaluated when requested, should match `action_cable_with_jwt_meta_tag`
    identified_by :current_user

    # `connect` is not being called via JWT authentication
    # def connect
    # end
  end
end
