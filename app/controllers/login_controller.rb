class LoginController < ApplicationController
  def index
    response.headers['X-XRDS-Location'] = url_for(:controller => "server",
                                                  :action => "idp_xrds",
                                                  :only_path => false)
    head :ok
  end
end
