require 'rails_helper'
require 'jwt'

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

  it 'should create a valid and signed ID token' do
    user = User.make!
    app = Application.make!

    token = user.create_openid_token_for(app)
    expect(token).to be_a(String)
    _, decoded_header = JWT.decode token, nil, false
    expect(decoded_header).to_not be_nil
    expect(decoded_header).to include('alg')
    payload, _ = JWT.decode token, app.secret, true, {algorithm: decoded_header['alg']}
    expect(payload['email']).to eq(user.email)
    expect(payload['exp']).to be > Time.now.to_i
    expect(payload['iat']).to be <= Time.now.to_i
  end
end
