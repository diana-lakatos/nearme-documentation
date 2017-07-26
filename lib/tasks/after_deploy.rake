namespace :after_deploy do
  desc 'Runs required tasks after deployment'
  task run: [:environment] do
    puts 'Clearing cache'
    Rails.cache.clear
    RedisCache.clear


    Delayed::Job.transaction do
      puts 'Removing all jobs from queue recurring-jobs'
      Delayed::Job.where(queue: 'recurring-jobs').delete_all

      puts 'Re-creating jobs for queue recurring-jobs'
      ScrapeSupportEmails.schedule!
      SchedulePaymentTransfers.schedule!
      SendSearchesDailyAlerts.schedule!
      PrepareFriendFinders.schedule!
      SendSearchesWeeklyAlerts.schedule!
      SendUnreadMessagesReminders.schedule!
      SendSpamReportsSummaryDaily.schedule!
      ScheduleChargeSubscriptions.schedule! if Rails.env.production?
      ScheduleCommunityAggregatesCreation.schedule!
      ScheduleSitemapsRefresh.schedule!
      ScheduleLongtailApiParse.schedule!
      ScheduleImportHallmarkUsers.schedule!
      ScheduleDevmeshExportDataUsers.schedule!
    end

    puts 'Creating default locales'
    Utils::EnLocalesSeeder.new.go!

    puts 'Refreshing themes'
    Theme.refresh_all!
  end
end
