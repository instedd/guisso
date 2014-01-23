class AccessTokensController < ApplicationController
  before_filter :authenticate_user!

  def index
    @tokens = current_user.access_tokens.valid
  end

  def destroy
    @token = current_user.access_tokens.find(params[:id])
    @token.destroy
    redirect_to access_tokens_url
  end
end
