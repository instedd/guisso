require 'rubygems'
require 'rack/oauth2'

YOUR_CLIENT_ID = "rXKiLsGY8OFQaYUZmf8pZw"
YOUR_CLIENT_SECRET = "zVwjKUL8iBc9PCpYgH9hzEkG38v6RTVokNg34r2kcH4"
YOUR_REDIRECT_URI = "http://localhost:3002/oauth2"

client = Rack::OAuth2::Client.new(
  :identifier => YOUR_CLIENT_ID,
  :secret => YOUR_CLIENT_SECRET,
  :redirect_uri => YOUR_REDIRECT_URI, # only required for grant_type = :code
  :host => 'localhost',
  :port => 3001,
  :scheme => 'http'
)

request_type = :code

puts "## request_type = :#{request_type}"

authorization_uri = case request_type
                    when :code
                      client.authorization_uri(:scope => "openid")
                    end

puts authorization_uri
