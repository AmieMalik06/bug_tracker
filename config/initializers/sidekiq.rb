require "sidekiq"
require "sidekiq-cron"

# Configure Redis connection for Sidekiq
Sidekiq.configure_server do |config|
  config.redis = { url: "redis://localhost:6379/0" }
end

Sidekiq.configure_client do |config|
  config.redis = { url: "redis://localhost:6379/0" }
end

# Schedule daily job at 9 AM
Sidekiq::Cron::Job.create(
  name: "Daily Report Job - every day at 9am",
  cron: "0 9 * * *",
  class: "DailyReportJob"
)
