namespace :after_deploy do
  desc 'Runs required tasks after deployment'
  task :run => [:environment] do
    puts "Clearing cache"
    Rails.cache.clear
    RedisCache.clear

    begin
      # puts 'Updating ES Transactables index mappings'
      # Transactable.__elasticsearch__.client.indices.put_mapping index: 'transactables', type: 'transactable', body: Transactable.mappings
      job_id = ElasticInstanceIndexerJob.perform.id
      puts "Updating ES documents id DJ ##{job_id}"
    rescue StandardError => e
      raise e if Rails.application.config.use_elastic_search
    end

    puts "Removing all jobs from queue recurring-jobs"
    Delayed::Job.where(queue: "recurring-jobs").delete_all

    puts "Re-creating jobs for queue recurring-jobs"
    # and queuing them again
    ScrapeSupportEmails.schedule!
    SchedulePaymentTransfers.schedule!
    SendSearchesDailyAlerts.schedule!
    PrepareFriendFinders.schedule!
    SendSearchesWeeklyAlerts.schedule!
    SendAnalyticsMails.schedule!
    SendUnreadMessagesReminders.schedule!
    SendSpamReportsSummaryDaily.schedule!
    ScheduleChargeSubscriptions.schedule! if Rails.env.production?
    ScheduleCommunityAggregatesCreation.schedule!
    ScheduleSitemapsRefresh.schedule!

    puts "Creating default locales"
    Utils::EnLocalesSeeder.new.go!

    puts "Notifying Raygun about deployment"
    RaygunDeployNotifier.send!

    puts "Refreshing themes"
    Theme.refresh_all!
  end

end

