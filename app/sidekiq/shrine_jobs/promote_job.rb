# frozen_string_literal: true

module ShrineJobs
  class PromoteJob
    include Sidekiq::Job

    def perform(attacher_class, record_class, record_id, name, file_data)
      attacher_class = Object.const_get(attacher_class)
      record = Object.const_get(record_class).find(record_id)
      attacher = attacher_class.retrieve(model: record, name: name, file: file_data)

      attacher.file.open do
        # since we allow direct uploads - user maliciously can send invalid metadata back to us,
        # to prevent that we refresh metadata before promoting
        attacher.refresh_metadata!
        # create derivatives using a cached file
        attacher.create_derivatives(attacher.file.tempfile)
      end

      attacher.atomic_promote
    rescue Shrine::AttachmentChanged, ActiveRecord::RecordNotFound
      # attachment has changed or record has been deleted, nothing to do
    end
  end
end
