require 'rails_helper'

describe PasswordsController do
  describe '#POST create' do
    let!(:user) { User.make! }

    before :each do
      @request.env["devise.mapping"] = Devise.mappings[:user]
    end

    it 'should report to telemetry' do
      expect(Telemetry::Auth).to receive(:reset_password)

      post :create, user: {email: user.email}
    end
  end
end
