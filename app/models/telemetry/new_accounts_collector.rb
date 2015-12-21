module Telemetry::NewAccountsCollector
  extend InsteddTelemetry::StatCollectors::Utils
  
  def self.collect_stats period
    count = User.where('created_at >= ? AND created_at < ?', period.beginning, period.end).count

    simple_counter('new_accounts', {}, count)
  end
end
