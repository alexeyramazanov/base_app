class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      # core
      t.string :email, null: false
      t.string :crypted_password
      t.string :salt

      # remember me
      t.string :remember_me_token
      t.datetime :remember_me_token_expires_at

      # user activation
      t.string :activation_state
      t.string :users, :activation_token
      t.datetime :activation_token_expires_at

      # reset password
      t.string :reset_password_token
      t.datetime :reset_password_token_expires_at
      t.datetime :reset_password_email_sent_at

      # activity logging
      t.datetime :last_login_at
      t.datetime :last_logout_at
      t.datetime :last_activity_at
      t.string :last_login_from_ip_address

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :remember_me_token
    add_index :users, :activation_token
    add_index :users, :reset_password_token
    add_index :users, [:last_logout_at, :last_activity_at]
  end
end
