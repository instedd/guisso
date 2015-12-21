module Telemetry::AccessedAccountsCollector
  extend InsteddTelemetry::StatCollectors::Utils

  def self.collect_stats(period)
    count = User.where('current_sign_in_at >= ? AND current_sign_in_at < ?', period.beginning, period.end).count


    simple_counter('accessed_accounts', {}, count)
  end
end
