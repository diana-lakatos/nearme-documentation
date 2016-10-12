# Unicorn self-process killer
require 'unicorn/worker_killer'
require 'delayed_job_web'

# Max memory size (RSS) per worker
use Unicorn::WorkerKiller::Oom, (650 * (1024**2)), (700 * (1024**2)), cycle_check = 16, verbose = (ENV['RAILS_ENV'] == 'staging')

if %w(staging production).include? ENV['RAILS_ENV']
  DelayedJobWeb.use Rack::Auth::Basic do |username, password|
    username == 'nearme_admin' && password == 'FsnEnVAs)C()'
  end
end

# This file is used by Rack-based servers to start the application.
require ::File.expand_path('../config/environment',  __FILE__)
run DesksnearMe::Application
