class Analytics::EventTrackerJob < Job
  def initialize(event_tracker, method, *args)
    @event_tracker = event_tracker
    @method = method
    @args = args
  end

  def perform
    @event_tracker.send(@method, *@args)
  end

end
