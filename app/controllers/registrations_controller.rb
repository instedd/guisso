class RegistrationsController < Devise::RegistrationsController
  prepend_before_action :check_captcha, only: [:create] if Guisso::Settings.recaptcha?

  def new
    if redirect_url = params[:redirect_url]
      session[:user_return_to] = redirect_url
    end
    super
  end

  def after_inactive_sign_up_path_for(resource)
    new_user_session_path
  end

  private
    def check_captcha
      unless verify_recaptcha
        self.resource = resource_class.new sign_up_params
        resource.validate # Look for any other validation errors besides reCAPTCHA
        respond_with_navigational(resource) { render :new }
      end 
    end
end
