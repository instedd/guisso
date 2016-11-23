# config valid only for current version of Capistrano
lock '3.6.1'

set :application, 'guisso'
set :repo_url, 'git@github.com:instedd/guisso.git'

ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

set :deploy_to, "/u/apps/#{fetch(:application)}"
set :scm, :git
set :format, :airbrussh
set :pty, true
set :keep_releases, 5
set :rails_env, :production
set :migration_role, :app

# Default value for :linked_files is []
append :linked_files, 'config/database.yml', 'config/newrelic.yml', 'config/settings.yml'

# Default value for linked_dirs is []
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache'

# Name for the exported service
set :service_name, fetch(:application)

namespace :service do
  task :safe_restart do
    on roles(:app) do
      execute "sudo stop #{fetch(:service_name)} ; sudo start #{fetch(:service_name)}"
    end
  end
end

namespace :deploy do
  after :restart, "service:safe_restart"
end
