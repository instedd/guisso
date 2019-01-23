class OpenIdController < ApplicationController
  skip_before_filter :verify_authenticity_token

  include OpenID::Server
  layout nil

  def index
    idp_xrds
  end

  def login
    oidreq = session[:last_oidreq]
    session[:last_oidreq] = nil

    return_to = params["openid.return_to"]
    if return_to && (query_string = CGI.parse(URI.parse(return_to).query)) && query_string["custom_message"].present?
      session[:custom_message] = query_string["custom_message"].first
    end

    unless oidreq
      begin
        oidreq = server.decode_request(params)

        # no openid.mode was given
        unless oidreq
          render :text => "This is an OpenID server endpoint."
          return
        end
      rescue ProtocolError => e
        # invalid openid request, so just display a page with an error message
        render :text => e.to_s, :status => 500
        return
      end
    end

    oidresp = nil

    if oidreq.kind_of?(CheckIDRequest)
      identity = oidreq.identity

      # The user has to choose an id in guisso
      if oidreq.id_select

        # The user wants to validate an id but no id is provided: something is wrong
        if oidreq.immediate
          oidresp = oidreq.answer(false)
          self.render_response(oidresp)
          return
        end

        # If we have a guisso user in session
        if current_user
          identity = url_for_user
        else
          show_devise_login(oidreq)
          return
        end
      end

      if oidresp
        nil
      elsif self.is_authorized(identity, oidreq.trust_root)
        oidresp = oidreq.answer(true, nil, identity)

        # add the sreg response if requested
        add_sreg(oidreq, oidresp)
        # ditto pape
        add_pape(oidreq, oidresp)

      elsif oidreq.immediate
        server_url = url_for :action => :login
        oidresp = oidreq.answer(false, server_url)

      else
        show_decision_page(oidreq)
        return
      end

    else
      oidresp = server.handle_request(oidreq)
    end

    self.render_response(oidresp)
  end

  def user_page
    # Yadis content-negotiation: we want to return the xrds if asked for.
    accept = request.env['HTTP_ACCEPT']

    # This is not technically correct, and should eventually be updated
    # to do real Accept header parsing and logic.  Though I expect it will work
    # 99% of the time.
    if accept and accept.include?('application/xrds+xml')
      user_xrds
      return
    end

    # content negotiation failed, so just render the user page
    xrds_url = url_for action: :user_xrds, email: params[:email]
    identity_page = <<EOS
<html><head>
<meta http-equiv="X-XRDS-Location" content="#{xrds_url}" />
<link rel="openid.server" href="#{url_for :action => :login}" />
</head><body><p>OpenID identity page for #{params[:email]}</p>
</body></html>
EOS

    # Also add the Yadis location header, so that they don't have
    # to parse the html unless absolutely necessary.
    response.headers['X-XRDS-Location'] = xrds_url
    render :text => identity_page
  end

  def user_xrds
    types = [
             OpenID::OPENID_2_0_TYPE,
             OpenID::OPENID_1_0_TYPE,
             OpenID::SREG_URI,
            ]

    render_xrds(types)
  end

  def idp_xrds
    types = [
             OpenID::OPENID_IDP_2_0_TYPE,
            ]

    render_xrds(types)
  end

  def decision
    oidreq = session[:last_oidreq]
    session[:last_oidreq] = nil

    if params[:yes].nil?
      redirect_to oidreq.cancel_url
      return
    else
      identity = url_for_user
      current_user.trusted_roots.create!(url: oidreq.trust_root)
      oidresp = oidreq.answer(true, nil, identity)
      add_sreg(oidreq, oidresp)
      add_pape(oidreq, oidresp)
      return self.render_response(oidresp)
    end
  end

  protected

  def show_devise_login(oidreq)
    session[:last_oidreq] = oidreq
    if oidreq.message.get_arg("http://instedd.org/guisso", "signup")
      redirect_to new_user_registration_path
    else
      redirect_to new_user_session_path
    end
  end

  def show_decision_page(oidreq)
    session[:last_oidreq] = oidreq
    @oidreq = oidreq
    @simple_registration_request = OpenID::SReg::Request.from_openid_request(oidreq)

    render :template => 'open_id/decide'
  end


  def server
    if @server.nil?
      server_url = url_for :action => :login, :only_path => false
      create_openid_store
      @server = Server.new(create_openid_store, server_url)
    end
    return @server
  end

  def create_openid_store
    store_config = Guisso::Settings.openid_store
    case store_config.scheme
    when "file"
      dir = Pathname.new(Rails.root).join(store_config.opaque || store_config.path)
      store = OpenID::Store::Filesystem.new(dir)
    when "memcache", "memcached"
      memcache_address = store_config.select(:host, :port).compact.join(":")
      memcache_client = Dalli::Client.new(memcache_address)
      store = OpenID::Store::Memcache.new(memcache_client)
    else
      raise "Invalid OpenID store config: #{store_config}"
    end
  end

  def url_for_user
    url_for action: :user_page, email: current_user.email
  end

  def approved(trust_root)
    trust_host = URI(trust_root).host
    return true if Guisso::Settings.whitelisted_hosts.any? { |host| trust_host.end_with? host }
    current_user.trusted_roots.where(url: trust_root).exists?
  end

  def is_authorized(identity_url, trust_root)
    return (current_user and (identity_url == url_for_user) and self.approved(trust_root))
  end

  def render_xrds(types)
    type_str = ""

    types.each { |uri|
      type_str += "<Type>#{uri}</Type>\n      "
    }

    yadis = <<EOS
<?xml version="1.0" encoding="UTF-8"?>
<xrds:XRDS
    xmlns:xrds="xri://$xrds"
    xmlns="xri://$xrd*($v*2.0)">
  <XRD>
    <Service priority="0">
      #{type_str}
      <URI>#{url_for(action: :login, only_path: false)}</URI>
    </Service>
  </XRD>
</xrds:XRDS>
EOS

    render :text => yadis, content_type: 'application/xrds+xml'
  end

  def add_sreg(oidreq, oidresp)
    # check for Simple Registration arguments and respond
    sregreq = OpenID::SReg::Request.from_openid_request(oidreq)

    return if sregreq.nil?
    # In a real application, this data would be user-specific,
    # and the user should be asked for permission to release
    # it.
    sreg_data = {
      'email' => current_user.email,
    }
    sreg_data['name'] = current_user.name if current_user.name.present?

    sregresp = OpenID::SReg::Response.extract_response(sregreq, sreg_data)
    oidresp.add_extension(sregresp)
  end

  def add_pape(oidreq, oidresp)
    papereq = OpenID::PAPE::Request.from_openid_request(oidreq)
    return if papereq.nil?
    paperesp = OpenID::PAPE::Response.new
    paperesp.nist_auth_level = 0 # we don't even do auth at all!
    oidresp.add_extension(paperesp)
  end

  def render_response(oidresp)
    if oidresp.needs_signing
      signed_response = server.signatory.sign(oidresp)
    end
    web_response = server.encode_response(oidresp)

    case web_response.code
    when HTTP_OK
      render :text => web_response.body, :status => 200
    when HTTP_REDIRECT
      puts web_response.headers['location']
      redirect_to web_response.headers['location']
    else
      render :text => web_response.body, :status => 400
    end
  end
end
