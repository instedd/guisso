require 'bundler/capistrano'
require 'rvm/capistrano'

set :rvm_ruby_string, '2.0.0-p353'
set :rvm_type, :system
set :application, "guisso"
set :repository,  "https://github.com/instedd/guisso"
set :scm, :git
set :user, 'ubuntu'
set :group, 'ubuntu'
set :deploy_via, :remote_cache

default_run_options[:pty] = true
default_environment['TERM'] = ENV['TERM']

after "deploy", "deploy:cleanup" # keep only the last 5 releases

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  task :symlink_configs, :roles => :app do
    %W(database.yml settings.yml newrelic.yml telemetry.yml).each do |file|
      run "test -e #{shared_path}/#{file} && ln -nfs #{shared_path}/#{file} #{release_path}/config/ || true"
    end
  end

  task :generate_version, :roles => :app do
    run "cd #{release_path} && git describe --always > #{release_path}/VERSION"
  end
end

before "deploy:start", "deploy:migrate"
before "deploy:restart", "deploy:migrate"

after "deploy:update_code", "deploy:symlink_configs"
after "deploy:update_code", "deploy:generate_version"
