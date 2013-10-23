require 'bundler/setup'
require 'rack/oauth2'
require 'pry'
require 'pry-byebug'

client = Rack::OAuth2::Client.new(
  :identifier => "vyk++Z1gg9Bl2QIlxAYndw==",
  :secret => "IxMncVyBpR/GjPqq9eoKgcqD4Tnr+8Mbo8yPeXD8Iod0F1zRU6dZEFiHbpgJJxPMmokSls/iuHa9MyBcNo9zbA==",
  :host => 'localhost',
  :port => 3000,
  :scheme => 'http',
  :redirect_uri => "http://foo.bar"
)

use_authorization_code = true

if use_authorization_code
  client.authorization_code = "C5SZxLFGujVo4TR44YAqRh/1uU74fHucJwpg9cL5EJIjKQSSXGh8bLhcgUraJJVcchh0i3GEjYkwJRyjdLOx7A=="
else
  client.scope = %w(app=resourcemap.instedd.org user=ary@esperanto.org.ar)
end

begin
  p client.access_token!
rescue => e
  p e
end
