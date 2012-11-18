class Listing
  module Search

    extend ActiveSupport::Concern

    included do
      attr_accessor :score, :strict_match

      def strict_match?
        strict_match.nil? || strict_match
      end

      define_index do
        join location
        join location.organizations
        where  "locations.id is not null"

        indexes :name, :description

        has "radians(#{Location.table_name}.latitude)",  as: :latitude,  type: :float
        has "radians(#{Location.table_name}.longitude)", as: :longitude, type: :float
        has :deleted_at

        # an organization id of 0 in the sphinx index means the entry does not require organization membership
        # (i.e the listing is public)
        has "CASE locations.require_organization_membership
          WHEN TRUE THEN array_to_string(array_agg(\"organizations\".\"id\"), ',')
          ELSE '0'
        END", as: :organization_ids, type: :multi

        group_by :latitude, :longitude, :require_organization_membership
      end

      sphinx_scope(:visible_for) do |user|
        orgs = (user) ? user.organization_ids : []
        orgs << 0

        { with: { organization_ids: orgs, deleted_at: 0 } }
      end

    end

    module ClassMethods

      def search_from_api(params, geocoder = nil)
        find_by_search_params(Params::Api.new(params, geocoder))
      end

      def search_from_web(params)
        find_by_search_params(Params::Web.new(params))
      end

      def find_by_search_params(params)
        if params.query
          listings = search(params.query, params.to_scope).to_a
        else
          listings = search(params.to_scope).to_a
        end


        Scorer.score(listings, params)

        listings.sort{|a,b| a.score <=> b.score }
      end
    end
  end
end
