# frozen_string_literal: true

class DocumentUploader < CarrierWave::Uploader::Base
  include CarrierWave::Vips

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_allowlist
    %w[jpg jpeg png]
  end

  def content_type_allowlist
    %r{image/}
  end

  version :thumb do
    process resize_to_fit: [200, 200]
  end
end
