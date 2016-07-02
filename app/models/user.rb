class User < ApplicationRecord
  authenticates_with_sorcery!

  validates :email, presence: true, uniqueness: true
  # length replaces presence validation, update_password is used to prevent empty passwords
  validates :password, length: { minimum: 6 }, if: -> { new_record? || changes[:crypted_password] || update_password }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }

  attr_accessor :update_password
end
