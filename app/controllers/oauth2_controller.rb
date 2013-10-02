class Oauth2Controller < ApplicationController
  def trusted_token
    resource = Application.find_by(identifier: params[:identifier], secret: params[:secret], trusted: true)
    unless resource
      return head :forbidden
    end

    access_token = AccessToken.valid.find_by(resource_id: resource.id, token: params[:token])
    unless access_token
      return head :forbidden
    end

    render json: {
      mac_key: access_token.secret,
      mac_algorithm: access_token.algorithm,
      user: access_token.user.email,
    }
  end
end