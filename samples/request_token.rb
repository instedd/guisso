require 'bundler/setup'
require 'rack/oauth2'
require 'pry'
require 'pry-byebug'

client = Rack::OAuth2::Client.new(
  :identifier => "9qVIhx03I2PkS8m7Mpc2zg==",
  :secret => "DuLm/OLD+GW63BI9H4orzsgSAAd6f5mbewW7yL8wlP9EeI5LKvAq5bny+tAe3N/rQpiUUszTryYr9nQFDASdfg==",
  :host => 'localhost',
  :port => 3001,
  :scheme => 'http',
)
client.scope = %w(app=resourcemap.instedd.org user=ary@esperanto.org.ar)

begin
  p client.access_token!
rescue => e
  p e
end