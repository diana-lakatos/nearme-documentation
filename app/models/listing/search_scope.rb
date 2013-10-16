class Listing
  class SearchScope

    def self.scope(request_context, options = {})
      if request_context.white_label_company
        Location.where(:"locations.company_id" => request_context.white_label_company.id)
      else
        search_scope = Location.joins(:company).where(companies: { listings_public: true })
        search_scope = search_scope.where(companies: { instance_id: request_context.instance.id }) unless request_context.instance.is_desksnearme?
        search_scope
      end
    end

  end
end
