# frozen_string_literal: true

class UserFile < ApplicationRecord
  self.inheritance_column = nil # disable STI for `type` column

  include UserFileUploader::Attachment(:attachment)

  MAX_FILE_SIZE = 10.megabytes
  IMAGE_MIME_TYPES = %w[image/jpg image/jpeg image/png].freeze
  IMAGE_EXTENSIONS = %w[jpg jpeg png].freeze
  DOCUMENT_MIME_TYPES = %w[application/pdf].freeze
  DOCUMENT_EXTENSIONS = %w[pdf].freeze
  SUPPORTED_MIME_TYPES = (IMAGE_MIME_TYPES + DOCUMENT_MIME_TYPES).freeze
  SUPPORTED_EXTENSIONS = (IMAGE_EXTENSIONS + DOCUMENT_EXTENSIONS).freeze

  enum :type, { image: 'image', document: 'document', unknown: 'unknown' }, default: :unknown, validate: true
  # TODO: aasm
  enum :status, { processing: 'processing', ready: 'ready', failed: 'failed' }, default: :processing, validate: true

  belongs_to :user

  validates :attachment, presence: true

  before_create :set_type

  def refresh_type!
    update_column(:type, detect_type) # rubocop:disable Rails/SkipsModelValidations
  end

  private

  def set_type
    self.type = detect_type
  end

  def detect_type
    case attachment.mime_type
    when *IMAGE_MIME_TYPES
      'image'
    when *DOCUMENT_MIME_TYPES
      'document'
    else
      'unknown'
    end
  end
end
