require 'chronic'

namespace :jira do
  task prepare: :environment do
    JiraWrapper::Releaser.new.prepare
  end

  desc 'Populate new foreign keys and flags'
  task release: :environment do
    JiraWrapper::Releaser.new.release(major: true)
  end

  task :release_minor do
    JiraWrapper::Releaser.new.release(major: false)
  end
end
