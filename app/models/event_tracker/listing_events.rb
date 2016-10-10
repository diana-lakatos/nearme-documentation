module EventTracker::ListingEvents
  def created_a_listing(listing, custom_options = {})
    track 'Created a Listing', listing, custom_options
  end

  def deleted_a_listing(listing, custom_options = {})
    track 'Deleted a Listing', listing, custom_options
  end

  def viewed_a_listing(listing, custom_options = {})
    track 'Viewed a Listing', listing, custom_options
  end
end
