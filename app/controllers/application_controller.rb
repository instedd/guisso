class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :set_default_host
  before_action :configure_permitted_parameters, if: :devise_controller?

  layout :layout_by_resource

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :name
    devise_parameter_sanitizer.for(:account_update) << :name
  end

  private

  def set_default_host
    ActionMailer::Base.default_url_options = {:host => request.host_with_port}
  end

  def after_sign_in_path_for(resource_or_scope)
    if session[:last_oidreq]
      '/openid/login'
    else
      session[:user_return_to].presence || root_path
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    params[:after_sign_out_url].presence || request.referrer || root_path
  end

  def layout_by_resource
    if devise_controller?
      "centred_form"
    else
      "application"
    end
  end
end
