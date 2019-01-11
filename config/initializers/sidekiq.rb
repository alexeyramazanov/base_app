schedule = Rails.root.join('config', 'schedule.yml')
yaml = YAML.load_file(schedule)

if Sidekiq.server? && yaml.present?
  Sidekiq::Cron::Job.load_from_hash(yaml)
end
