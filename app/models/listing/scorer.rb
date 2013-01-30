class Listing
  class Scorer

    WEIGHTINGS = {
      search_area:   0.4,
      amenities:     0.15,
      price:         0.15,
      availability:  0.15
    }.freeze

    attr_accessor :listings, :scores, :strict_matches

    def self.score(listing_set, search_parameters)
      new(listing_set).score(search_parameters)
    end

    def initialize(listings)

      self.listings = listings

      # scores and strict_matches are hashes of score components/booleans :)
      self.scores         = Hash.new { |h, k| h[k] = {} }
      self.strict_matches = self.scores.dup
    end

    def score(search_parameters)
      @listings.reject! { |l| l.nil? || l.location.nil? }

      WEIGHTINGS.keys.each do |component|
        if params = search_parameters.send(component)
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

    def score_search_area(search_area)
      ranked_listings =  @listings.rank_by do |l|
        if l.sphinx_attributes && l.sphinx_attributes["@geodist"]
          l.sphinx_attributes["@geodist"]
        else
          search_area.distance_from(l.latitude, l.longitude)
        end
      end

      add_scores(ranked_listings, :search_area)
    end

    def score_amenities(amenity_ids = [])
      ranked_listings       = @listings.rank_by { |l| (amenity_ids - l.location.amenity_ids).size }

      add_strict_matches(:amenities) { |l| (amenity_ids - l.location.amenity_ids).size == 0 }
      add_scores(ranked_listings, :amenities)
    end

    def score_price(price_range)

      ranked_listings = @listings.rank_by { |l| ((l.price_cents || 0) - price_range.midpoint_cents).abs }

      add_strict_matches(:price) do |l|
        price_range.include_cents?(l.price_cents)
      end

      add_scores(ranked_listings, :price)
    end

    def score_availability(availability)
      add_strict_matches(:availability) do |l|
        availability.dates.all? do |day|
          l.availability_for(day) >= availability.min
        end
      end

      # FIXME: this is going to do a query for each day!
      # should be able to request listing availability over a date range easily enough...
      ranked_listings = @listings.rank_by do |l|
        availability.dates.inject(0) do |sum, day|
          sum += ([l.desks_booked_on(day), availability.min].max / availability.min)
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
