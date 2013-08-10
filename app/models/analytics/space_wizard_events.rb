module Analytics::SpaceWizardEvents

  def clicked_list_your_bookable
    track 'Clicked List your Bookable'
  end

  def viewed_list_your_bookable
    track "Viewed List Your First Bookable"
  end

end

