require 'rails_helper'

describe SessionsController do
  before :each do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe 'POST #create' do
    it 'reports failed login to telemetry' do
      expect(InsteddTelemetry).to receive(:counter_add).with('wrong_password_attempts', {}, 1)

      post :create, user: {email: 'foo@bar.com', password: '123'}
    end
  end
end
