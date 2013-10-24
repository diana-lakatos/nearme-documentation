class Listing
  class SearchScope

    def self.scope(platform_context, options = {})
      if platform_context.white_label_company
        Location.where(:"locations.company_id" => platform_context.white_label_company.id)
      else
        search_scope = Location.joins(:company).where(companies: { listings_public: true })
        search_scope = search_scope.where(companies: { instance_id: platform_context.instance.id }) unless platform_context.instance.is_desksnearme?
        search_scope = search_scope.where(companies: { partner_id: platform_context.partner.id }) if platform_context.partner && platform_context.partner.search_scope_option.all_associated_listings?
        search_scope
      end
    end

  end
end
