set :branch, "master"
set :deploy_user, 'ec2-user'
set :force_local_version_matches_deployed, true
set :service_name, "guisso"

server 'login.instedd.org', user: fetch(:deploy_user), roles: %w{app web db}
