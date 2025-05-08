# frozen_string_literal: true

class CreateDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :documents do |t|
      t.references :user, null: false

      t.jsonb :file_data

      t.timestamps
    end

    add_index :documents, :file_data, using: 'gin'
  end
end
