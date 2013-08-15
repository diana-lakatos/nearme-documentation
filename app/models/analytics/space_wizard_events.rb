module Analytics::SpaceWizardEvents

  def clicked_list_your_bookable(custom_options = {})
    track 'Clicked List your Bookable', custom_options
  end

  def viewed_list_your_bookable
    track "Viewed List Your First Bookable"
  end

end

