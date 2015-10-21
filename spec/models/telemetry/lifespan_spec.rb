require 'rails_helper'

describe Telemetry::Lifespan do
  let(:now) { Time.now }
  let(:from) { now - 1.week }

  before :each do
    Timecop.freeze(now)
  end

  after :each do
    Timecop.return
  end

  it 'updates the account lifespan' do
    user = User.make created_at: from

    expect(InsteddTelemetry).to receive(:timespan_update).with('account_lifespan', {account_id: user.id}, user.created_at, now)

    Telemetry::Lifespan.touch_user user
  end
end
