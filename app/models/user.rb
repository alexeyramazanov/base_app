class User < ApplicationRecord
  # NOTE: fixes 'ArgumentError: To use reset_password submodule, you must define a mailer' error.
  # Current master is broken because of combination of 2 PRs:
  # https://github.com/Sorcery/sorcery/issues/137
  # https://github.com/Sorcery/sorcery/pull/209
  # Waiting for Sorcery 0.15+
  include Sorcery::Controller

  extend Enumerize

  authenticates_with_sorcery!

  enumerize :role, in: %w[ user admin ], default: 'user', predicates: true

  validates :email, presence: true, uniqueness: true
  # length replaces presence validation, update_password is used to prevent empty passwords
  validates :password, length: { minimum: 6 }, if: -> { new_record? || changes[:crypted_password] || update_password }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }

  attr_accessor :update_password
end
