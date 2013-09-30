# Contains methods related to Inspectlet.
#
class AnalyticWrapper::Inspectlet

  TAGGABLE_EVENTS = ['Requested a booking', 'Created a location',
  'Created a listing', 'Saved a draft', 'Signed up', 'Logged in' ]

  def self.taggable?(event)
    TAGGABLE_EVENTS.include?(event)
  end
end
