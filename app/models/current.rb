# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :session

  delegate :user, :admin_user, to: :session, allow_nil: true
end
