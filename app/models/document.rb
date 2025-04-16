# frozen_string_literal: true

class Document < ApplicationRecord
  include DocumentUploader::Attachment(:file)

  belongs_to :user
end
