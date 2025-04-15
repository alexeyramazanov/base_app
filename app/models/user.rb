# frozen_string_literal: true

class User < ApplicationRecord
  include Authentication

  has_many :chat_messages, dependent: :delete_all

  after_create_commit lambda {
    broadcast_prepend_to 'admin_new_users', partial: 'admin/dashboard/new_user_row',
                         locals: { user: User.last }, target: 'admin_new_users'
  }
end
