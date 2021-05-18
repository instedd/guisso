source 'https://rubygems.org'

gem 'puma', '~> 4.3.8'
gem 'rails', '~> 4.2.0'
gem 'mysql2', '~> 0.5.2'
gem 'pg', '~> 0.11'
gem 'jquery-rails', '~> 3.1.3'
gem 'jbuilder', '~> 1.2'
gem 'haml'
gem 'haml-rails'
gem 'ruby-openid'
gem 'devise', '3.4.0'
gem 'omniauth', '~> 1.3.2'
gem 'omniauth-openid'
gem 'omniauth-google-oauth2'
gem 'activerecord-session_store'
gem 'rack-oauth2', :git => "https://github.com/instedd/rack-oauth2.git", branch: "feature/openid-connect"
gem 'cancan'
gem 'enumerated_attribute', :git => "https://github.com/ssendev/enumerated_attribute.git"
gem 'newrelic_rpm'
gem 'instedd-bootstrap', git: "https://github.com/instedd/instedd-bootstrap.git", branch: 'master'
gem "instedd-rails", '>= 0.0.25'
gem 'simple_form'
gem 'env_rails'
gem 'instedd_telemetry', git: 'https://github.com/instedd/telemetry_rails.git'
gem 'intercom-rails'
gem 'dalli'
gem 'recaptcha'

group :doc do
  gem 'sdoc', require: false
end

group :development, :test do
  gem 'rspec-rails'
  gem 'test-unit'
  gem 'pry-byebug'
  gem 'capistrano',         '~> 3.6', :require => false
  gem 'capistrano-rails',   '~> 1.2', :require => false
  gem 'capistrano-bundler', '~> 1.2', :require => false
  gem 'capistrano-rvm',               :require => false
  gem 'rails-dev-tweaks', '~> 1.1'
end

group :test do
  gem 'machinist'
  gem 'ffaker'
  gem 'timecop'
end

group :assets do
  gem 'sass-rails', '~> 4.0.0'
  gem 'uglifier', '>= 1.3.0'
  gem 'coffee-rails', '~> 4.0.0'
end
