class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_filter :verify_authenticity_token, :only => [:google]

  def google
    generic do |auth|
      {email: auth.info['email'], name: auth.info['name']}
    end
  end

  def generic
    auth = env['omniauth.auth']

    if identity = Identity.find_by(provider: auth['provider'], token: auth['uid'])
      user = identity.user
    else
      attributes = yield auth

      attributes[:confirmed_at] = Time.now

      user = User.find_by(email: attributes[:email])
      unless user
        password = Devise.friendly_token
        user = User.create!(attributes.merge(password: password, password_confirmation: password))
      end
      user.identities.create! provider: auth['provider'], token: auth['uid']
    end

    sign_in user
    next_url = env['omniauth.origin'] || root_path
    next_url = root_path if next_url == new_user_session_url
    redirect_to next_url
  end
end
