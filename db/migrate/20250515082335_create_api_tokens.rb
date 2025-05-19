# frozen_string_literal: true

class CreateApiTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :api_tokens do |t|
      t.references :user

      t.string :token, null: false
      t.datetime :last_used_at

      t.timestamps
    end
  end
end
