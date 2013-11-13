# Contains methods related to client side events.
#
class AnalyticWrapper::ClientEvents

  TAGGABLE_EVENTS = ['Requested a booking', 'Created a location',
  'Created a listing', 'Saved a draft', 'Signed up', 'Logged in' ]

  def self.taggable?(event)
    TAGGABLE_EVENTS.include?(event)
  end
end
