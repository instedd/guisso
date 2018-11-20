class HomeController < ApplicationController
  after_action :intercom_shutdown, only: [:index]

  def index
  end

  protected
  def intercom_shutdown
    IntercomRails::ShutdownHelper.intercom_shutdown(session, cookies, request.domain)
  end
end
