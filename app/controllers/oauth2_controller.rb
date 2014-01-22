class Oauth2Controller < ApplicationController
  before_filter :authenticate_user!, except: [:trusted_token]

  rescue_from Rack::OAuth2::Server::Authorize::BadRequest do |e|
    if @redirect_uri.present?
      char = @redirect_uri.query ? '&' : '?'
      redirect_to "#{@redirect_uri}#{char}error=#{e.error}"
    end
  end

  def trusted_token
    resource = Application.find_by(identifier: params[:identifier], secret: params[:secret], trusted: true)
    unless resource
      return head :forbidden
    end

    access_token = AccessToken.valid.find_by(resource_id: resource.id, token: params[:token])
    unless access_token
      return head :forbidden
    end

    render json: access_token
  end

  def authorize
    respond *authorize_endpoint.call(request.env)
  end

  def create_authorization
    respond *authorize_endpoint(:allow_approval).call(request.env)
  end

  private

  def respond(status, header, response)
    if response.redirect?
      redirect_to header['Location']
    end
  end

  def authorize_endpoint(allow_approval = false)
    Rack::OAuth2::Server::Authorize.new do |req, res|
      @client = Application.find_by(identifier: req.client_id) or req.bad_request!
      res.redirect_uri = @redirect_uri = req.redirect_uri #req.verify_redirect_uri!(@client.hostname)

      @scope = req.scope

      @resource = nil
      req.scope.each do |scope|
        key, value = scope.split '=', 2
        case key
        when 'app'
          @resource = Application.find_by(hostname: value)
        end
      end

      unless @resource
        req.bad_request!
      end

      if allow_approval
        if params[:approve]
          case req.response_type
          when :code
            authorization_code = current_user.authorization_codes.create(client_id: @client.id, resource_id: @resource.id, redirect_uri: res.redirect_uri.to_s)
            res.code = authorization_code.token
          # when :token
          #   res.access_token = current_user.access_tokens.create(:client_id => @client).to_token
          end
          res.approve!
        else
          req.access_denied!
        end
      else
        @response_type = req.response_type
      end
    end
  end
end
