class SessionsController < Devise::SessionsController
  skip_before_filter :verify_authenticity_token, :only => [:destroy]

  def new
    @custom_message = session[:custom_message]
    session.delete(:custom_message)
    super
  end
end
