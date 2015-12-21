class PasswordsController < Devise::PasswordsController

  def create
    super
    Telemetry::Auth.reset_password if successfully_sent?(resource)
  end

end
