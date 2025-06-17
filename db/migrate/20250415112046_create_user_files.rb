# frozen_string_literal: true

class CreateUserFiles < ActiveRecord::Migration[8.0]
  def change
    create_table :user_files do |t|
      t.references :user, null: false
      t.string :type, null: false
      t.string :status, null: false

      t.jsonb :attachment_data, null: false, default: {}

      t.timestamps
    end

    add_index :user_files, :attachment_data, using: 'gin'
  end
end
