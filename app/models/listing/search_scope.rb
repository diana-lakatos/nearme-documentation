class Listing
  class SearchScope

    def self.scope(request_context, options = {})
      if request_context.white_label_company
        Location.where(:"locations.company_id" => request_context.white_label_company.id)
      else
        search_scope = Location.joins(:company).where(companies: { listings_public: true })
        search_scope = search_scope.where(companies: { instance_id: request_context.instance.id }) unless request_context.is_desksnearme?
        search_scope = search_scope.where(companies: { partner_id: request_context.partner.id }) if request_context.partner && request_context.partner.search_scope_option.all_associated_listings?
        search_scope
      end
    end

  end
end
