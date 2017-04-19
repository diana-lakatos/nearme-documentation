module ElasticIndexer
  class GeoLocationSerializer < ActiveModel::Serializer
    self.root = false

    def attributes
      return unless valid?

      {
        lat: latitude,
        lon: longitude
      }
    end

    private

    def valid?
      location&.latitude && location&.longitude
    end

    def location
      object.current_address
    end

    def latitude
      location.latitude.to_f
    end

    def longitude
      location.longitude.to_f
    end
  end
end
