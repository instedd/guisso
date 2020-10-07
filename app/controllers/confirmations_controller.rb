class ConfirmationsController < Devise::ConfirmationsController
  prepend_before_action :check_captcha, only: [:create] if Guisso::Settings.recaptcha?

  private
    def check_captcha
      unless verify_recaptcha
        self.resource = resource_class.new
        respond_with_navigational(resource) { render :new }
      end 
    end
end
