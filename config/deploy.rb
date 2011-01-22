require 'rubygems'
require 'bundler/setup'
require 'thinking_sphinx/deploy/capistrano'
require 'bundler/capistrano'

$:.unshift(File.expand_path('./lib', ENV['rvm_path']))  # Add RVM's lib directory to the load path.
require "rvm/capistrano"                                # Load RVM's capistrano plugin.
set :rvm_ruby_string, '1.9.2'                           # Or whatever env you want it to run in.
set :rvm_type, :user

set :user, "deploy"
set :application, "desksnearme"
set :repository,  "git@github.com:keithpitt/desksnearme.git"
set :deploy_to, "/var/apps/#{application}"
set :use_sudo, false

set :scm, :git

task :staging do
  set :rvm_bin_path, "/usr/local/bin/"
  role :web, "173.255.213.129"
  role :app, "173.255.213.129"
  role :db,  "173.255.213.129", :primary => true
  role :db,  "173.255.213.129"
end

task :production do
  role :web, "desksnear.me"                          # Your HTTP server, Apache/etc
  role :app, "desksnear.me"                          # This may be the same as your `Web` server
  role :db,  "desksnear.me", :primary => true        # This is where Rails migrations will run
  role :db,  "desksnear.me"
  set :branch, "production"
end

after "deploy:symlink" do
  run "ln -s #{release_path}/config/database.ci.yml #{release_path}/config/database.yml"
  run "cd #{current_path}; rake db:migrate RAILS_ENV=production --trace"
  sudo "ln -sf #{current_path}/config/logrotate.conf /etc/logrotate.d/desksnearme.conf"
  sudo "ln -sf #{current_path}/config/nginx.conf /opt/nginx/conf/vhosts/desksnearme.conf"
end

after "deploy:symlink", "deploy:nginx:reload", "thinking_sphinx:stop", "thinking_sphinx:configure", "thinking_sphinx:start"


namespace :deploy do

  task :start do ; end
  task :stop do ; end

  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  namespace :nginx do
    init = "/etc/init.d/nginx"

    task :configtest do
      run "#{init} configtest"
    end

    task :reload => :configtest do
      run "#{init} reload"
    end

    task :restart => :configtest do
      run "#{init} restart"
    end
  end


end

after "deploy:setup", "thinking_sphinx:shared_sphinx_folder"

