# This task handles all our periodic jobs, which is triggered by crond
namespace :cron do
  desc "Run hourly scheduled jobs"
  task :hourly => [:environment] do
    run_job "Send Rating reminders" do
      RatingReminderJob.perform(Time.zone.today.to_s)
    end
  end

  desc "Run daily scheduled jobs"
  task :daily => [:environment] do 
    run_job "Send Share mails" do
      RecurringMailerShareJob.perform
    end

    #run_job "Send Request photos mails" do
    #  RecurringMailerRequestPhotosJob.perform
    #end
  end

  desc "Run weekly scheduled jobs"
  task :weekly => [:environment] do
    run_job "Send Analytics mails" do
      RecurringMailerAnalyticsJob.perform
    end

    run_job "Find new social connections" do
      PrepareFriendFindersJob.perform
    end
  end

  desc "Run monthly scheduled jobs"
  task :monthly => [:environment] do
    run_job "Schedule Payment Transfers" do
      PaymentTransferSchedulerJob.perform
    end
  end
end

# Execute a block ('job'), but rescue and report on errors and then
# continue.
def run_job(name, &blk)
  PlatformContext.clear_current
  puts "#{Time.now} | Executing #{name}"
  begin
    yield
  rescue
    puts "#{Time.now} | Encountered error"
    puts $!.inspect
    Raygun.track_exception($!)
  end
  puts "#{Time.now} | Done"
end

