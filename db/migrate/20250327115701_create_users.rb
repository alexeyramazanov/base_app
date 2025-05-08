# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false

      t.string :activation_state, default: 'pending'
      t.string :activation_token
      t.datetime :activation_token_expires_at

      t.string :reset_password_token
      t.datetime :reset_password_token_expires_at

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :activation_token, unique: true
    add_index :users, :reset_password_token, unique: true
  end
end
