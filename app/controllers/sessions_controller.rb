class SessionsController < Devise::SessionsController
  skip_before_filter :verify_authenticity_token, :only => [:destroy]
  after_action :prepare_intercom_shutdown, only: [:destroy]

  def new
    @custom_message = session[:custom_message]
    session.delete(:custom_message)
    super
  end

  protected
  def prepare_intercom_shutdown
    IntercomRails::ShutdownHelper.prepare_intercom_shutdown(session)
  end
end
