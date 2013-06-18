module Analytics::ListingEvents

  def created_a_listing(listing, custom_options = {})
    track 'Created a Listing', listing, custom_options
  end

end

