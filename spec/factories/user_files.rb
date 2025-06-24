# frozen_string_literal: true

FactoryBot.define do
  factory :user_file do
    transient do
      skip_promotion { false }
    end

    user

    attachment { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/sample.jpg')) }

    # based on code from sidekiq/lib/sidekiq/testing.rb
    after(:create) do |user_file, evaluator|
      next if evaluator.skip_promotion

      job_class = ShrineJobs::PromoteUserFileJob

      job = job_class.jobs.find do |j|
        ([user_file.class.to_s, user_file.id] - j['args']).empty?
      end
      Sidekiq::Queues.delete_for(job['jid'], job['queue'], job_class.to_s)
      job_class.process_job(job)

      # get updated state
      user_file.reload
    end
  end
end
