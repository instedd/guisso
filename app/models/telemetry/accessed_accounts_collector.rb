module Telemetry::AccessedAccountsCollector
  def self.collect_stats(period)
    count = User.where('current_sign_in_at >= ? AND current_sign_in_at < ?', period.beginning, period.end).count

    {
      metric: 'accessed_accounts',
      key: {},
      value: count
    }
  end
end
