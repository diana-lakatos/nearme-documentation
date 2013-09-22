class LocationPolicy

  def self.scope(white_label_company = nil)
    if white_label_company.present?
      white_label_company.locations
    else
      Location.scoped
    end
  end

end
