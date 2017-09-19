class RegistrationsController < Devise::RegistrationsController
  def new
    if redirect_url = params[:redirect_url]
      session[:user_return_to] = redirect_url
    end
    super
  end

  def after_inactive_sign_up_path_for(resource)
    new_user_session_path
  end
end
