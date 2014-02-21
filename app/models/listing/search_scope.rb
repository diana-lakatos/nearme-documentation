class Listing
  class SearchScope

    def self.scope(platform_context, options = {})
      if platform_context.white_label_company
        Location.where(:"locations.company_id" => platform_context.white_label_company.id)
      else
        search_scope = Location.where(:"locations.listings_public" => true )
        search_scope = search_scope.where(:"locations.instance_id" => platform_context.instance.id)
        search_scope = search_scope.joins(:company).where(companies: { partner_id: platform_context.partner.id }) if platform_context.partner && platform_context.partner.search_scope_option.all_associated_listings?
        search_scope
      end
    end

  end
end
