require 'rails_helper'

describe User do
  it 'should touch lifespan on create' do
    user = User.make

    expect(Telemetry::Lifespan).to receive(:touch_user).with(user)

    user.save
  end

  it 'should touch lifespan on update' do
    user = User.make!
    user.touch

    expect(Telemetry::Lifespan).to receive(:touch_user).with(user)

    user.save
  end

  it 'should touch lifespan on destroy' do
    user = User.make!

    expect(Telemetry::Lifespan).to receive(:touch_user).with(user)

    user.destroy
  end
end
