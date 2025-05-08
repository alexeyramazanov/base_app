# frozen_string_literal: true

class DocumentUploader < Shrine
  Attacher.validate do
    validate_mime_type %w[image/jpeg image/png]
    validate_extension %w[jpg jpeg png]
  end

  Attacher.derivatives do |original|
    vips = ImageProcessing::Vips.source(original)

    {
      thumb: vips.resize_to_limit!(100, 100)
    }
  end

  # fall back to the original file URL when the derivative is missing
  Attacher.default_url do |derivative: nil, **|
    file&.url if derivative
  end
end
