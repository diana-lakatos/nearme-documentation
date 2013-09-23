# Contains methods related to Inspectlet.
#
class AnalyticWrapper::Inspectlet

  TAGGABLE_EVENTS = ['requested_a_booking', 'created_a_location',
  'created_a_listing', 'saved_a_draft', 'signed_up', 'logged_in' ]

  def self.tags(triggered_events)
    triggered_events ||= []
    (triggered_events & TAGGABLE_EVENTS).map do |event|
      event.humanize
    end
  end
end
