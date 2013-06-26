require "dropbox-api/tasks"

namespace :dropbox do
  desc "create rake task for dropbox"
  task :start => :environment do
    Dropbox::API::Tasks.install
    Rake::Task["dropbox:authorize"].invoke
  end
end
