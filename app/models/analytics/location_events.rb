module Analytics::LocationEvents

  def created_a_location(location, custom_options = {})
    track 'Created a Location', location, custom_options
  end

  def viewed_a_location(location, custom_options = {})
    track 'Viewed a Location', location, custom_options
  end

  def conducted_a_search(search, custom_options = {})
    track 'Conducted a Search', search, custom_options
  end

  def subscribed_for_search_notification(search_notification, custom_options= {})
    track 'Subscribed for a search notification', search_notification, custom_options
  end

end

