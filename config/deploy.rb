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

namespace :service do
  task :restart do
    on roles(:app) do
      if fetch(:service_name) && fetch(:service_name).size != 0
        execute "sudo stop #{fetch(:service_name)} ; sudo start #{fetch(:service_name)}"
      else
        execute "sudo touch #{release_path}/tmp/restart.txt"
      end
    end
  end
end

namespace :deploy do
  after :publishing, :restart
  after :restart, "service:restart"

  after :updated, :export_version do
    on roles(:app) do
      within release_path do
        version = capture "git --git-dir #{repo_path} describe --tags #{fetch(:current_revision)}"
        execute :echo, "#{version} > VERSION"
      end
    end
  end

end
