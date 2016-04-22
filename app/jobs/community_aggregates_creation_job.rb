class CommunityAggregatesCreationJob < Job
  include Job::LongRunning

  def after_initialize
  end

  def perform
    CommunityAggregatesCreationService.new.create_aggregates
  end
end
