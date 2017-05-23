# frozen_string_literal: true
class RemoveOldMarketplaceReportsJob < Job
  include Job::LongRunning

  def after_initialize
  end

  def perform
    MarketplaceReport.where('created_at < ?', 30.days.ago).find_each do |marketplace_report|
      marketplace_report.remove_zip_file!
      marketplace_report.destroy
    end
  end
end
