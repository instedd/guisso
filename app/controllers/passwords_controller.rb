class PasswordsController < Devise::PasswordsController
  prepend_before_action :check_captcha, only: [:create] if Guisso::Settings.recaptcha?

  def create
    super
    Telemetry::Auth.reset_password if successfully_sent?(resource)
  end

  private
    def check_captcha
      unless verify_recaptcha
        self.resource = resource_class.new
        respond_with_navigational(resource) { render :new }
      end
    end
end
