module Telemetry::NewAccountsCollector
  def self.collect_stats period
    count = User.where('created_at >= ? AND created_at < ?', period.beginning, period.end).count

    {
      metric: 'new_accounts',
      key: {},
      value: count
    }
  end
end
