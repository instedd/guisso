require 'rails_helper'

describe Telemetry::AccessedAccountsCollector, telemetry: true do
  it 'counts accessed accounts by period' do
    User.make! current_sign_in_at: to - 1.day
    User.make! current_sign_in_at: to - 2.days
    User.make! current_sign_in_at: to - 5.days
    User.make! current_sign_in_at: to + 1.day
    User.make! current_sign_in_at: from - 1.day

    stats = Telemetry::AccessedAccountsCollector.collect_stats period

    expect(stats).to eq({
      metric: 'accessed_accounts',
      key: {},
      value: 3
    })
  end
end
