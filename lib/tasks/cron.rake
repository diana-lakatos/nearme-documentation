# This task handles all our periodic jobs, which is triggered by crond
namespace :cron do
  desc "Run hourly scheduled jobs"
  task :hourly => [:environment] do
    run_job "Send Rating reminders" do
      RatingReminderJob.new(Time.zone.today.to_s).perform
    end
  end

  desc "Run daily scheduled jobs"
  task :daily => [:environment] do
  end

  desc "Run weekly scheduled jobs"
  task :weekly => [:environment] do
  end

  desc "Run monthly scheduled jobs"
  task :monthly => [:environment] do
    run_job "Schedule Payment Transfers" do
      PaymentTransferSchedulerJob.new.perform
    end
  end
end

# Execute a block ('job'), but rescue and report on errors and then
# continue.
def run_job(name, &blk)
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

