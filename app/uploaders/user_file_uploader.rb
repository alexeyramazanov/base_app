# frozen_string_literal: true

class UserFileUploader < Shrine
  Attacher.validate do
    validate_max_size UserFile::MAX_FILE_SIZE
    validate_extension UserFile::SUPPORTED_EXTENSIONS
    validate_mime_type UserFile::SUPPORTED_MIME_TYPES
  end

  Attacher.derivatives do |original|
    next {} unless record.image?

    vips = ImageProcessing::Vips.source(original)

    {
      preview: vips.resize_to_limit!(300, 300)
    }
  end

  # fall back to the original file URL when the derivative is missing
  Attacher.default_url do |derivative: nil, **|
    file&.url if derivative
  end

  Attacher.promote_block do
    ShrineJobs::PromoteUserFileJob.perform_async(self.class.name, record.class.name, record.id, name.to_s, file_data)
  end
end
