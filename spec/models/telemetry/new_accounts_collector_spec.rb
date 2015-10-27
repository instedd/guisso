require 'rails_helper'

describe Telemetry::NewAccountsCollector, telemetry: true do
  it 'counts new accounts by period' do
    User.make! created_at: to - 1.day
    User.make! created_at: to - 2.days
    User.make! created_at: to - 5.days
    User.make! created_at: to + 1.day
    User.make! created_at: from - 1.day

    stats = Telemetry::NewAccountsCollector.collect_stats period

    expect(stats).to eq({
      counters: [{
        metric: 'new_accounts',
        key: {},
        value: 3
      }]
    })
  end
end
