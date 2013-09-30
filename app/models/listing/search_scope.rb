class Listing
  class SearchScope

    def self.scope(instance, options = {})
      if options[:white_label_company].try(:white_label_enabled?)
        Location.where(:"locations.company_id" => options[:white_label_company].id)
      else
        Location.joins(:company).where(companies: { listings_public: true, instance_id: instance.id })
      end
    end

  end
end
