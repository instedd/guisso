RSpec.shared_examples "user lifespan" do |klass|
  let!(:user) { User.make! }

  it 'should touch lifespan on create' do
    record = klass.make user: user

    expect(Telemetry::Lifespan).to receive(:touch_user).with(user)

    record.save
  end

  it 'should touch lifespan on update' do
    record = klass.make! user: user
    record.touch

    expect(Telemetry::Lifespan).to receive(:touch_user).with(user)

    record.save
  end
end
