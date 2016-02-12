require 'benchmark'

namespace :webpack do
  desc 'compile bundles using webpack'
  task :compile do
    puts 'DEPRECATED: Use gulp build:dist instead'
  end

  task :test do
    puts 'DEPRECATED: Use gulp build:test instead'
  end
end
