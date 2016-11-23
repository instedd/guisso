# From https://gist.github.com/dsandstrom/4e6d118b4ca22e0fc7d40d40c5a8f22d

# Runs rake assets:clean
# Defaults to nil (no asset cleanup is performed)
# If you use Rails 4+ and you'd like to clean up old assets after each deploy,
# set this to the number of versions to keep
set :keep_assets, nil

# Validate that the local version is the same as the deployed one,
# so the assets are compiled for the correct version
set :force_local_version_matches_deployed, true

# Clear existing task so we can replace it rather than "add" to it.
Rake::Task["deploy:compile_assets"].clear

namespace :deploy do
  desc 'Compile assets'
  task :compile_assets => [:set_rails_env] do
    # invoke 'deploy:assets:precompile'
    invoke 'deploy:assets:force_local_version_matches_deployed'
    invoke 'deploy:assets:copy_manifest'
    invoke 'deploy:assets:precompile_local'
    invoke 'deploy:assets:backup_manifest'
  end

  namespace :assets do
    local_dir = "./public/assets/"

    desc 'Validate working version'
    task force_local_version_matches_deployed: [:set_rails_env] do
      on roles(fetch(:assets_roles, [:web])) do
        if fetch(:force_local_version_matches_deployed)
          current_revision = fetch(:current_revision)
          run_locally do
            working_revision = capture("git rev-parse HEAD")
            if current_revision != working_revision
              raise "Working directory and deployed revision must be the same in order to compile assets locally\nDeploying: #{fetch(:current_revision)}\nWorking:   #{working_revision}"
            end
          end
        end
      end
    end

    # Download the asset manifest file so a new one isn't generated. This makes
    # the app use the latest assets and gives Sprockets a complete manifest so
    # it knows which files to delete when it cleans up.
    desc 'Copy assets manifest'
    task copy_manifest: [:set_rails_env] do
      on roles(fetch(:assets_roles, [:web])) do
        remote_dir = "#{fetch(:deploy_user)}@#{host.hostname}:#{shared_path}/public/assets/"

        run_locally do
          begin
            execute "mkdir #{local_dir}"
            execute "scp '#{remote_dir}.sprockets-manifest-*' #{local_dir}"
          rescue
            # no manifest yet
          end
        end
      end
    end

    desc "Precompile assets locally and then rsync to web servers"
    task :precompile_local do
      # compile assets locally
      run_locally do
        execute "RAILS_ENV=production bundle exec rake assets:precompile"
      end

      # rsync to each server
      on roles(fetch(:assets_roles, [:web])) do
        # this needs to be done outside run_locally in order for host to exist
        remote_dir = "#{fetch(:deploy_user)}@#{host.hostname}:#{shared_path}/public/assets/"

        run_locally do
          execute "rsync -av #{local_dir} #{remote_dir}"
        end
      end

      # clean up
      run_locally { execute "rm -rf #{local_dir}" }
    end
  end
end
