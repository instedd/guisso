# NB: Deploy to staging adding RVM=1 before the `cap deploy` command
set :branch, 'release/1.2'
set :deploy_user, 'ubuntu'
set :force_local_version_matches_deployed, true
set :service_name, nil

set :rvm_type, :system
set :rvm_ruby_version, '2.0.0-p353'

server 'login-stg.instedd.org', user: fetch(:deploy_user), roles: %w{app web db}
