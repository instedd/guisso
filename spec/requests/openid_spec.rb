require 'rails_helper'

describe "OpenID" do
  it "gets identity page" do
    get "/openid/user@email.com"
    assert_select "meta[http-equiv=X-XRDS-Location]" do |meta|
      expect(meta.first["content"]).to eq("http://www.example.com/openid/user@email.com/xrds")
    end
    assert_select "link[rel=openid.server]" do |link|
      expect(link.first["href"]).to eq("http://www.example.com/openid/login")
    end
  end

  it "gets xrds page from identity url using accept header" do
    get "/openid/user@email.com", nil, {accept: "application/xrds+xml"}
    xrds = OpenID::Yadis.parseXRDS(response.body)
    service = OpenID::Yadis.services(xrds).first
    types, uri = OpenID::Yadis.expand_service(service).first
    expect(types).to eq([OpenID::OPENID_2_0_TYPE, OpenID::OPENID_1_0_TYPE, OpenID::SREG_URI])
    expect(uri).to eq("http://www.example.com/openid/login")
  end

  it "gets xrds page" do
    get "/openid/user@email.com/xrds"
    xrds = OpenID::Yadis.parseXRDS(response.body)
    service = OpenID::Yadis.services(xrds).first
    types, uri = OpenID::Yadis.expand_service(service).first
    expect(types).to eq([OpenID::OPENID_2_0_TYPE, OpenID::OPENID_1_0_TYPE, OpenID::SREG_URI])
    expect(uri).to eq("http://www.example.com/openid/login")
  end

  it "gets server xrds" do
    get "/openid/xrds"
    xrds = OpenID::Yadis.parseXRDS(response.body)
    service = OpenID::Yadis.services(xrds).first
    types, uri = OpenID::Yadis.expand_service(service).first
    expect(types).to eq([OpenID::OPENID_IDP_2_0_TYPE])
    expect(uri).to eq("http://www.example.com/openid/login")
  end
end
