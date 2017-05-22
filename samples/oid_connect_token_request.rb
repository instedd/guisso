require 'rubygems'
require 'rack/oauth2'
require 'jwt'

YOUR_CLIENT_ID = "rXKiLsGY8OFQaYUZmf8pZw"
YOUR_CLIENT_SECRET = "zVwjKUL8iBc9PCpYgH9hzEkG38v6RTVokNg34r2kcH4"
YOUR_REDIRECT_URI = "http://localhost:3002/oauth2"

YOUR_AUTHORIZATION_CODE = ARGV[0]

client = Rack::OAuth2::Client.new(
  :identifier => YOUR_CLIENT_ID,
  :secret => YOUR_CLIENT_SECRET,
  :redirect_uri => YOUR_REDIRECT_URI, # only required for grant_type = :code
  :host => 'web',
  :port => 3000,
  :scheme => 'http'
)

grant_type = :authorization_code

puts "## grant_type = :#{grant_type}"

case grant_type
when :authorization_code
  client.authorization_code = YOUR_AUTHORIZATION_CODE
end

begin
  token = client.access_token!
  p token.access_token
  p token.id_token
  p JWT.decode(token.id_token, nil, false)
rescue => e
  p e
end
