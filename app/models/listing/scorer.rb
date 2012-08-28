class Listing
  class Scorer

    WEIGHTINGS = {
      boundingbox:   0.4,
      amenities:     0.15,
      organizations: 0.15,
      price:         0.15,
      availability:  0.15
    }.freeze

    attr_accessor :listings, :scores, :strict_matches

    def self.score(listing_set, search_parameters)
      new(listing_set).score(search_parameters)
    end

    def initialize(listings)

      # eager load some stuff so we don't do quite as many queries
      # self.listings = Listing.where(id: listings.map(&:id)).includes(:photos).includes(location: [ :organizations, :company, :amenities ]).all
      self.listings = listings

      # scores and strict_matches are hashes of score components/booleans :)
      self.scores         = Hash.new { |h, k| h[k] = {} }
      self.strict_matches = self.scores.dup
    end

    def score(search_parameters)
      WEIGHTINGS.keys.each do |component|
        if params = search_parameters.delete(component)
          send("score_#{component}", params)
        end
      end

      @listings.each do |l|
        l.strict_match = self.strict_matches[l].all? { |component, is_match| is_match }

        l.score = WEIGHTINGS.inject(0) do |score, weighting_pair|
          component_name, weighting = weighting_pair
          score += self.scores[l][component_name] * weighting if self.scores[l][component_name]
          score
        end.round(2)
      end
    end

    private

      # Ascending proximity to center of `boundingbox`, normalised between 0 and 100
      def score_boundingbox(options = {})
        options.symbolize_keys!

        center_lat, center_lon = options.delete(:lat), options.delete(:lon)
        ranked_listings        =  @listings.rank_by do |l|
          if l.sphinx_attributes && l.sphinx_attributes["@geodist"]
            l.sphinx_attributes["@geodist"]
          else
            l.distance_from(center_lat, center_lon)
          end
        end

        # Note that we don't set the strict_matches here - because we are usually passed
        # a set of listings within a bounding box, so we ignore this component for strict matches

        add_scores(ranked_listings, :boundingbox)
      end

      def score_amenities(amenity_ids = [])
        amenity_ids.map!(&:to_i)
        ranked_listings       = @listings.rank_by { |l| (amenity_ids - l.location.amenity_ids).size }

        add_strict_matches(:amenities) { |l| (amenity_ids - l.location.amenity_ids).size == 0 }
        add_scores(ranked_listings, :amenities)
      end

      # this feels like you could DRY it with the above - but seems to add complexity for
      # not a lot of benefit at the monement
      def score_organizations(organization_ids = [])
        organization_ids.map!(&:to_i)
        ranked_listings = @listings.rank_by { |l| (organization_ids - l.location.organization_ids).size }

        add_strict_matches(:organizations) { |l| (organization_ids - l.location.organization_ids).size == 0 }
        add_scores(ranked_listings, :organizations)
      end

      def score_price(options = {})
        options.symbolize_keys!

        min_cents, max_cents = (options.delete(:min).to_i || 0) * 100, (options.delete(:max).to_i || 0) * 100
        midpoint_cents       = (max_cents + min_cents) / 2

        ranked_listings = @listings.rank_by { |l|(l.price_cents - midpoint_cents).abs }

        add_strict_matches(:price) { |l|  l.price_cents >= min_cents && l.price_cents <= max_cents }
        add_scores(ranked_listings, :price)
      end

      def score_availability(options = {})
        options.symbolize_keys!

        start_date, end_date = options.delete(:date_start).to_date, options.delete(:date_end).to_date
        quantity_needed      = options.delete(:quantity_min).to_i

        add_strict_matches(:availability) do |l|
          (start_date...end_date).all? { |day| l.availability_for(day) >= quantity_needed }
        end

        # FIXME: this is going to do a query for each day!
        # should be able to request listing availability over a date range easily enough...
        ranked_listings = @listings.rank_by do |l|
          (start_date...end_date).inject(0) do |sum, day|
            sum += ([l.desks_booked_on(day), quantity_needed].max / quantity_needed)
            sum
          end
        end

        add_scores(ranked_listings, :availability)
      end

      def add_scores(ranked_listings, component_name)
        ranked_listings.each_with_index do |listings, rank|
          listings.each do |l|
            scores[l][component_name] = normalize_rank(rank + 1, @listings.size)
          end
        end
      end

      def add_strict_matches(component_name, &block)
        @listings.each do |l|
          strict_matches[l][component_name] = block.call(l)
        end
      end

      def normalize_rank(rank, number_of_ranks)
        ((rank / number_of_ranks.to_f) * 100).round(2)
      end

  end
end