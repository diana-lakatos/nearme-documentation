require 'rubygems'
require 'bundler/setup'
require 'thinking_sphinx/deploy/capistrano'
require 'bundler/capistrano'
require 'capushka'

set :user, "deploy"
set :application, "desksnearme"
set :repository,  "git@github.com:keithpitt/desksnearme.git"
set :deploy_to, "/var/apps/#{application}"
set :use_sudo, false

ssh_options[:forward_agent] = true

set :scm, :git

task :rvm do
  $:.unshift(File.expand_path('./lib', ENV['rvm_path']))  # Add RVM's lib directory to the load path.
  require "rvm/capistrano"                                # Load RVM's capistrano plugin.
  set :rvm_ruby_string, '1.9.2-p0'                        # Or whatever env you want it to run in.
end

before :staging, :rvm
task :staging do
  set :rvm_bin_path, "/usr/local/bin/"
  role :web, "173.255.213.129"
  role :app, "173.255.213.129"
  role :db,  "173.255.213.129", :primary => true
  role :db,  "173.255.213.129"
  set :rvm_type, :system
end

before :production, :rvm
task :production do
  role :web, "desksnear.me"                          # Your HTTP server, Apache/etc
  role :app, "desksnear.me"                          # This may be the same as your `Web` server
  role :db,  "desksnear.me", :primary => true        # This is where Rails migrations will run
  role :db,  "desksnear.me"
  set :branch, "production"
  set :rvm_type, :user
end

task :ec2 do
  set :branch, "production"
  role :web, "desks"
  role :app, "desks"
  set :user, application
  set :rvm_type, :none

  before "deploy:setup" do
    with_user "ubuntu" do
      sudo %Q{bash -c "`wget -O- babushka.me/up/hard`"}
      sudo "mkdir -p /var/apps"
      sudo "chmod 777 /var/apps"

      babushka 'benhoskings:set.locale'
      babushka 'benhoskings:admins can sudo'
      babushka 'benhoskings:user exists', {:username => old_user}
      babushka 'benhoskings:passwordless ssh logins'
    end
  end

  after "deploy:update_code" do
    with_user "ubuntu" do
      babushka 'deploy'
    end
  end
end

after "deploy:symlink" do
  run "ln -s #{release_path}/config/database.ci.yml #{release_path}/config/database.yml"
  run "cd #{current_path}; rake db:migrate RAILS_ENV=production --trace"
  sudo "ln -sf #{current_path}/config/logrotate.conf /etc/logrotate.d/desksnearme.conf"
  sudo "ln -sf #{current_path}/config/nginx.conf /opt/nginx/conf/vhosts/desksnearme.conf"
end

after "deploy:symlink", "deploy:nginx:reload", "thinking_sphinx:stop", "thinking_sphinx:configure", "thinking_sphinx:start"
after "deploy:setup", "thinking_sphinx:shared_sphinx_folder"

namespace :deploy do
  task :start do ; end
  task :stop do ; end

  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  namespace :nginx do
    before :reload, :configtest
    before :restart, :configtest

    init = "/etc/init.d/nginx"

    task :configtest do
      sudo "#{init} configtest"
    end

    task :reload do
      sudo "#{init} reload"
    end

    task :restart do
      sudo "#{init} restart"
    end
  end
end

def with_user(new_user)
  old_user = user
  set :user, new_user
  yield
  set :user, old_user
end

        require './config/boot'
        require 'hoptoad_notifier/capistrano'
