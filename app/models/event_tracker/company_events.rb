module EventTracker::CompanyEvents
  def created_a_company(company, custom_options = {})
    track 'Created a Company', company, custom_options
  end
end
