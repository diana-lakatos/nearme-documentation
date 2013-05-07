module Analytics::LocationEvents
  def created_a_location(location, custom_options = {})
    track_event 'Created a Location', location, custom_options
  end

  def viewed_a_location(location, custom_options = {})
    track_event 'Viewed a Location', location, custom_options
  end

  def conducted_a_search(search, custom_options = {})
    track_event 'Conducted a Search', search, custom_options
  end
end

