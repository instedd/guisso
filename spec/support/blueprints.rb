require 'machinist/active_record'

Application.blueprint do
  name { Faker::Name.name }
  hostname { Faker::Internet.domain_name }
  identifier { Oauth2::SecureToken.generate(16) }
  secret { Oauth2::SecureToken.generate }
  redirect_uris { ["http://#{Faker::Internet.domain_name}/callback"] }
end

User.blueprint do
  email { Faker::Internet.email }
  password { Faker::Name.name[0..10] }
  confirmed_at { 2.days.ago }
end

ExtraPassword.blueprint do
  password { Faker::Name.name[0..10] }
end

AuthorizationCode.blueprint do
end

AccessToken.blueprint do
end

BearerAccessToken.blueprint do
end

TrustedRoot.blueprint do
end
