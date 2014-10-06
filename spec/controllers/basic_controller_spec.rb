require 'rails_helper'

describe BasicController do
  let(:trusted_app) { Application.make!(trusted: true) }
  let(:untrusted_app) { Application.make!(trusted: false) }
  let(:user) { User.make! }

  it "forbids if request doesn't have authorization header" do
    get :check
    expect(response).to have_http_status(:forbidden)
  end

  it "accepts valid user" do
    set_authorization_header(trusted_app)
    get :check, {email: user.email, password: user.password}
    expect(response).to have_http_status(:ok)
  end

  it "forbids non trusted app" do
    set_authorization_header(untrusted_app)
    get :check, {email: user.email, password: user.password}
    expect(response).to have_http_status(:forbidden)
  end

  it "forbids non existing app" do
    app = Application.make(trusted: true)
    set_authorization_header(app)
    get :check, {email: user.email, password: user.password}
    expect(response).to have_http_status(:forbidden)
  end

  it "forbids non exising user" do
    set_authorization_header(trusted_app)
    get :check, {email: "foo", password: "bar"}
    expect(response).to have_http_status(:forbidden)
  end

  it "forbids with invalid password" do
    set_authorization_header(trusted_app)
    get :check, {email: user.email, password: "foo"}
    expect(response).to have_http_status(:forbidden)
  end

  it "accepts extra password" do
    extra_pwd = user.extra_passwords.make!
    set_authorization_header(trusted_app)
    get :check, {email: user.email, password: extra_pwd.password}
    expect(response).to have_http_status(:ok)
  end

  def set_authorization_header(app)
    request.env['HTTP_AUTHORIZATION'] = "Basic #{::Base64.strict_encode64("#{app.identifier}:#{app.secret}")}"
  end
end
