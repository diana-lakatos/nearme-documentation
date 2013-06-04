module Analytics::SpaceWizardEvents

  def viewed_list_your_space_sign_up
    track 'Viewed List Your Space, Sign Up'
  end

  def viewed_list_your_space_list
    track 'Viewed List Your Space, List'
  end

end

