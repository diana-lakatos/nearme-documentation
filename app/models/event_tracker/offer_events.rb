module EventTracker::OfferEvents

  def created_an_offer(offer, custom_options = {})
    track 'Created an Offer', offer, custom_options
  end

end