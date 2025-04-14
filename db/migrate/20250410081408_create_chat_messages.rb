# frozen_string_literal: true

class CreateChatMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :chat_messages do |t|
      t.references :user, null: false

      t.string :room
      t.string :message

      t.timestamps
    end
  end
end
