# frozen_string_literal: true

module MailerHelpers
  # this helper exists only because `have_enqueued_sidekiq_job` matcher doesn't support parameterized mailers
  def enqueued_mailers # rubocop:disable Metrics/AbcSize
    mailer_queue = Rails.application.config.action_mailer.deliver_later_queue_name.to_s

    Sidekiq::Queues[mailer_queue].map do |job|
      args = ActiveJob::Arguments.deserialize(job['args'][0]['arguments'])
      enqueued_at = DateTime.parse(job['args'][0]['enqueued_at'])
      scheduled_at = job['args'][0]['scheduled_at'].present? ? DateTime.parse(job['args'][0]['scheduled_at']) : nil

      {
        class:           args[0],
        action:          args[1],
        delivery_method: args[2],
        params:          args[3][:params],
        args:            args[3][:args],
        enqueued_at:     enqueued_at,
        scheduled_at:    scheduled_at
      }
    end
  end
end
