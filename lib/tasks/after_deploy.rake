namespace :after_deploy do
  desc 'Runs required tasks after deployment'
  task :run => [:environment] do
    ['after_deploy:clear_rails_cache', 'reprocess:css', 'locales:create_or_update_defaults', 'after_deploy:schedule_recurring_jobs'].each do |task_name|
      p "[#{Time.now}]Invoking: #{task_name}"
      Rake::Task[task_name].invoke
    end
  end

  desc "Clear Rails cache"
  task :clear_rails_cache => [:environment] do
    Rails.cache.clear
    RedisCache.clear
  end

  desc "Schedule Recurring Jobs"
  task :schedule_recurring_jobs => [:environment] do
    # removing all recurring jobs from previous deployment/application restart
    Delayed::Job.where(queue: "recurring-jobs").delete_all

    # and queuing them again
    ScrapeSupportEmails.schedule!
    SendRatingReminders.schedule!
    SchedulePaymentTransfers.schedule!
    SendSearchesDailyAlerts.schedule!
    PrepareFriendFinders.schedule!
    SendSearchesWeeklyAlerts.schedule!
    SendAnalyticsMails.schedule!
    SendUnreadMessagesReminders.schedule!

  end
end
