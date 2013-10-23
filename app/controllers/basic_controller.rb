class BasicController < ApplicationController
  def check
    return head :forbidden unless request.authorization && request.authorization =~ /^Basic (.*)/m
    client_id, client_secret = Base64.decode64($1).split(/:/, 2)

    app = Application.find_by(identifier: client_id, secret: client_secret, trusted: true)
    unless app
      return head :forbidden
    end

    user = User.find_by_email params[:email]
    unless user
      return head :forbidden
    end

    if user.valid_password?(params[:password]) || user.extra_passwords.any? { |extra| extra.valid_password?(params[:password]) }
      return head :ok
    end

    head :forbidden
  end
end
