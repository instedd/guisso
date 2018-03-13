class Oauth2Controller < ApplicationController
  before_filter :authenticate_user!, except: [:trusted_token]

  rescue_from Rack::OAuth2::Server::Authorize::BadRequest do |e|
    if @redirect_uri.present?
      char = @redirect_uri.query ? '&' : '?'
      redirect_to "#{@redirect_uri}#{char}error=#{e.error}"
    else
      head :bad_request
    end
  end

  def trusted_token
    resource = Application.find_by(identifier: params[:identifier], secret: params[:secret])
    unless resource
      return head :forbidden
    end

    access_token = AccessToken.valid.find_by(resource_id: resource.id, token: params[:token])
    unless access_token
      return head :forbidden
    end

    # Report to telemetry
    access_token.report_tool_usage

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
      res.redirect_uri = @redirect_uri = req.verify_redirect_uri!(@client.redirect_uris)

      @scope = req.scope
      @normalized_scope = Authorization.normalize_scope(req.scope).join(' ')
      @state = req.state
      @response_type = req.response_type

      @resource = nil
      req.scope.each do |scope|
        key, value = scope.split '=', 2
        case key
        when 'app'
          @resource = Application.find_by(hostname: value)
        when 'openid'
          @resource = @client
        end
      end

      unless @resource
        req.bad_request!
      end

      if approved?(allow_approval)
        if @authorization
          @authorization.add_scope(@normalized_scope)
          @authorization.save!
        else
         @authorization = current_user.authorizations.create(client_id: @client.id, resource_id: @resource.id, scope: @normalized_scope)
        end

        case req.response_type
        when :code
          authorization_code = current_user.authorization_codes.create(client_id: @client.id, resource_id: @resource.id, redirect_uri: res.redirect_uri.to_s, scope: @normalized_scope)
          res.code = authorization_code.token
        when :token
          token = current_user.access_tokens.create(client_id: @client.id, resource_id: @resource.id, type: "BearerAccessToken", expires_at: 1.hour.from_now)
          res.access_token = token.to_token
        else
          req.bad_request!
        end
        res.approve!
      end

      if denied?(allow_approval)
        req.access_denied!
      end
    end
  end

  def approved?(allow_approval)
    @authorization = current_user.authorizations.find_by(client: @client, resource: @resource)
    return true if allow_approval && params[:approve]
    return @authorization != nil && @authorization.includes_scope?(@normalized_scope)
  end

  def denied?(allow_approval)
    allow_approval && !params[:approve]
  end
end
