# frozen_string_literal: true

require 'shrine'
require 'shrine/storage/s3'
require 'shrine/storage/file_system'
require 'image_processing/vips'

if Rails.env.test?
  Shrine.storages = {
    cache: Shrine::Storage::FileSystem.new('tmp/storage', prefix: 'cache'),
    store: Shrine::Storage::FileSystem.new('tmp/storage', prefix: 'store')
  }
else
  s3_options = {
    access_key_id:     ENV.fetch('AWS_ACCESS_KEY_ID', nil),
    secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY', nil),
    region:            ENV.fetch('AWS_REGION', 'us-east-1'),
    bucket:            ENV.fetch('AWS_BUCKET', 'base-app'),
    endpoint:          ENV.fetch('AWS_ENDPOINT', nil),
    force_path_style:  ENV.fetch('AWS_PATH_STYLE', nil)
  }

  Shrine.storages = {
    cache: Shrine::Storage::S3.new(prefix: 'cache', **s3_options),
    store: Shrine::Storage::S3.new(prefix: 'store', **s3_options)
  }
end

Shrine.plugin :activerecord
Shrine.plugin :validation_helpers
Shrine.plugin :determine_mime_type, analyzer: :marcel
Shrine.plugin :default_url
Shrine.plugin :derivatives
Shrine.plugin :backgrounding
Shrine.plugin :data_uri
Shrine.plugin :upload_options,
              cache: { acl: 'private', cache_control: "public, max-age=#{365.days.to_i}" },
              store: { acl: 'private', cache_control: "public, max-age=#{365.days.to_i}" }
Shrine.plugin :presign_endpoint, presign_options: lambda { |request|
  {
    content_length_range: 0..(10 * 1024 * 1024), # 10 MB
    content_disposition:  ContentDisposition.inline(request.params['filename']),
    content_type:         request.params['type']
  }
}

Shrine::Attacher.promote_block do
  ShrineJobs::PromoteJob.perform_async(self.class.name, record.class.name, record.id, name.to_s, file_data)
end
Shrine::Attacher.destroy_block do
  ShrineJobs::DestroyJob.perform_async(self.class.name, data)
end
