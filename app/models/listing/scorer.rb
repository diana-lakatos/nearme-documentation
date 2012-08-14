class Listing
  class Scorer

    WEIGHTINGS = {
      boundingbox:   0.4,
      amenities:     0.15,
      associations:  0.15,
      price:         0.15,
      date_quantity: 0.15
    }.freeze

    attr_accessor :listings, :scores

    def self.score(listing_set, search_parameters)
      new(listing_set).score(search_parameters)
    end

    def initialize(listings)
      self.listings = listings

      # scores is a hash of score components :)
      self.scores = @listings.inject({}) do |h, l|
        h[l] = {}
        h
      end
    end

    def score(search_parameters)

      @listings.each { |l| l.score_components ||= {} }

      score_boundingbox(search_parameters.delete(:boundingbox))

      # listings.each do |l|
      #   l.score = WEIGHTINGS.inject(0) do |score, pair|
      #     # scoring component and what the relative weight of it should be
      #     component, weight = pair
      #     score += send("score_#{component}")
      #     score
      #   end
      # end
    end

    private

      # Ascending proximity to center of `boundingbox`, normalised between 0 and 100
      def score_boundingbox(options)
        center_lat, center_lon = options.delete(:lat), options.delete(:lon)
        ranked_listings        =  @listings.rank_by { |l| l.distance_from(center_lat, center_lon) }

        ranked_listings.each_with_index do |listings, rank|
          listings.each do |l|
            scores[l][:boundingbox] = ((rank / ranked_listings.size.to_f) * 10_000).round / 100.0
          end
        end
      end

      def score_amenities

      end

  end
end