# frozen_string_literal: true

require 'shrine'
require 'shrine/storage/s3'
require 'image_processing/vips'

s3_options = {
  access_key_id:     ENV.fetch('AWS_ACCESS_KEY_ID'),
  secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY'),
  region:            ENV.fetch('AWS_REGION'),
  bucket:            ENV.fetch('AWS_BUCKET'),
  endpoint:          ENV.fetch('AWS_ENDPOINT'),
  force_path_style:  ENV.fetch('AWS_PATH_STYLE')
}

Shrine.storages = {
  cache: Shrine::Storage::S3.new(prefix: 'cache', **s3_options),
  store: Shrine::Storage::S3.new(prefix: 'store', **s3_options)
}

Shrine.plugin :activerecord
Shrine.plugin :validation_helpers
Shrine.plugin :determine_mime_type, analyzer: :mime_types
Shrine.plugin :default_url
Shrine.plugin :derivatives
Shrine.plugin :backgrounding
Shrine.plugin :upload_options,
              cache: { acl: 'private', cache_control: "public, max-age=#{365.days.to_i}" },
              store: { acl: 'private', cache_control: "public, max-age=#{365.days.to_i}" }

Shrine::Attacher.promote_block do
  ShrineJobs::PromoteJob.perform_async(self.class.name, record.class.name, record.id, name.to_s, file_data)
end
Shrine::Attacher.destroy_block do
  ShrineJobs::DestroyJob.perform_async(self.class.name, data)
end
