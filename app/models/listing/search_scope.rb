class Listing
  class SearchScope

    def self.scope(instance, options = {})
      if options[:white_label_company].try(:white_label_enabled?)
        Location.where(:"locations.company_id" => options[:white_label_company].id)
      else
        search_scope = Location.joins(:company).where(companies: { listings_public: true })
        search_scope = search_scope.where(companies: { instance_id: instance.id }) unless instance.is_desksnearme?
        search_scope
      end
    end

  end
end
