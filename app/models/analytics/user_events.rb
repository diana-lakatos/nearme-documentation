module Analytics::UserEvents

  def signed_up(user, custom_options = {})
    set_person_properties user, custom_options
    track 'Signed Up', user, custom_options
  end

  def updated_profile_information(user, custom_options = {})
    set_person_properties user, custom_options
  end

  def logged_in(user, custom_options = {})
    set_person_properties user, custom_options
    track 'Logged In', user, custom_options
  end

  def connected_social_provider(user, custom_options = {})
    set_person_properties user, custom_options
    track 'Connected Social Provider', user, custom_options
  end

  def disconnected_social_provider(user, custom_options = {})
    set_person_properties user, custom_options
    track 'Disconnected Social Provider', user, custom_options
  end

  def submitted_a_rating(user, custom_options = {})
    set_person_properties user, custom_options
    track 'Submitted a rating', user, custom_options
  end

  def photo_not_processed_before_submit(user, custom_options = {})
    set_person_properties user, custom_options
    track 'Photo not processed before form submit', user, custom_options 
  end

  def user_closed_browser_photo_not_processed_before_submit(user, custom_options = {})
    set_person_properties user, custom_options
    track 'User closed browser window when photo not processed before form submit', user, custom_options 
  end
end

