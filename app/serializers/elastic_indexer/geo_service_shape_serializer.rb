module ElasticIndexer
  class GeoServiceShapeSerializer < ActiveModel::Serializer
    self.root = false
    def attributes
      return unless valid?

      GeoCirleSerializer.new(location: location, radius: radius).as_json
    end

    private

    def valid?
      location&.latitude && location&.longitude
    end

    def location
      object.current_address
    end

    def radius
      object.seller_profile.properties['service_radius']
    end
  end

  class GeoCirleSerializer
    attr_reader :radius, :location

    def initialize(radius:, location:)
      @radius = radius
      @location = location
    end

    def as_json(*args)
      {
        type: type,
        coordinates: coordinates,
        radius: radius
      }
    end

    private

    def type
      'circle'
    end

    def coordinates
      [longitude, latitude]
    end

    def latitude
      location.latitude.to_f
    end

    def longitude
      location.longitude.to_f
    end
  end
end
