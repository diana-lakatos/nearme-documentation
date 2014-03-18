# Unicorn self-process killer
require 'unicorn/worker_killer'

# Max memory size (RSS) per worker
use Unicorn::WorkerKiller::Oom, (200*(1024**2)), (250*(1024**2))

# This file is used by Rack-based servers to start the application.
require ::File.expand_path('../config/environment',  __FILE__)
run DesksnearMe::Application
