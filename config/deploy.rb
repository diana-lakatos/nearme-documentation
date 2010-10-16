set :user, "deploy"
set :application, "desksnearme"
set :repository,  "git@github.com:railsrumble/rr10-team-154.git"
set :deploy_to, "/var/apps/#{application}"
set :use_sudo, false

set :scm, :git

role :web, "desksnear.me"                          # Your HTTP server, Apache/etc
role :app, "desksnear.me"                          # This may be the same as your `Web` server
role :db,  "desksnear.me", :primary => true # This is where Rails migrations will run
role :db,  "desksnear.me"

after "deploy:symlink", "deploy:update_crontab"

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
  desc "Update the crontab file"
  task :update_crontab, :roles => :db do
    run "cd #{release_path} && whenever --update-crontab #{application}"
  end
end
