# frozen_string_literal: true

class Document < ApplicationRecord
  belongs_to :user

  mount_uploader :file, DocumentUploader
end
