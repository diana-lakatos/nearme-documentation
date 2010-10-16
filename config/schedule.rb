# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
set :output, "/var/apps/desksnearme/shared/log/cron.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

job_type :rvm_rake, "cd :path && RAILS_ENV=:environment /home/deploy/.rvm/bin/rake :task"

every 10.minutes do
  rvm_rake "ts:index"
end

# Learn more: http://github.com/javan/whenever
