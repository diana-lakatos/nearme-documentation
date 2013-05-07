module Analytics::SpaceWizardEvents
  def viewed_list_your_space_sign_up
    track_event 'Viewed List Your Space, Sign Up'
  end

  def viewed_list_your_space_list
    track_event 'Viewed List Your Space, List'
  end
end

