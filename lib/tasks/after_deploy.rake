namespace :after_deploy do
  desc 'Runs required tasks after deployment'
  task run: [:environment] do
    puts 'Clearing cache'
    Rails.cache.clear
    RedisCache.clear

    # This section will be rebuilt to use alias mechanism
    # Instance.pluck(:id).each do |instance_id|
    #   job_id = ElasticInstanceIndexerJob.perform('Instance', instance_id).id
    #   puts "Updating ES documents for instance #{instance_id} DJ##{job_id}"
    # end if Rails.application.config.use_elastic_search

    puts 'Removing all jobs from queue recurring-jobs'
    Delayed::Job.where(queue: 'recurring-jobs').delete_all

    puts 'Re-creating jobs for queue recurring-jobs'
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
    ScheduleLongtailApiParse.schedule!

    puts 'Creating default locales'
    Utils::EnLocalesSeeder.new.go!

    puts 'Refreshing themes'
    Theme.refresh_all!
  end
end
