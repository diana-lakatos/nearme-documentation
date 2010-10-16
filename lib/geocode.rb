# Stolen from: http://github.com/alexreisner/geocoder/raw/master/lib/geocoder.rb
module Geocode

  class Result

    VALID_PARTS = %w(street_address route intersection political country administrative_area_level_1
                  administrative_area_level_2 administrative_area_level_3 colloquial_area locality
                  sublocality neighborhood premise subpremise postal_code natural_feature airport
                  park point_of_interest post_box street_number floor room)

    attr_reader :doc, :parts, :name, :latitude, :longitude

    def initialize(doc)
      @doc = doc
      @name = doc['formatted_address']
      @latitude = doc['geometry']['location']['lat']
      @longitude = doc['geometry']['location']['lng']

      @parts = {}
      address_components = doc['address_components']
      if address_components
        address_components.each do |c|
          c['types'].each do |t| 
            @parts[t] = c['long_name'] if VALID_PARTS.include?(t)
          end
        end
      end
    end

  end

  ##
  # Query Google for geographic information about the given phrase.
  # Returns a hash representing a valid geocoder response.
  # Returns nil if non-200 HTTP response, timeout, or other error.
  #
  def self.search(query)
    doc = _fetch_parsed_response(query)
    doc && doc['status'] == "OK" ? doc['results'].map { |d| Result.new(d) } : nil
  end

  ##
  # Returns a parsed Google geocoder search result (hash).
  # This method is not intended for general use (prefer Geocoder.search).
  #
  def self._fetch_parsed_response(query)
    if doc = _fetch_raw_response(query)
      ActiveSupport::JSON.decode(doc)
    end
  end

  ##
  # Returns a raw Google geocoder search result (JSON).
  # This method is not intended for general use (prefer Geocoder.search).
  #
  def self._fetch_raw_response(query)
    return nil if query.blank?

    # build URL
    params = { :address => query, :sensor  => "false" }
    url = "http://maps.google.com/maps/api/geocode/json?" + params.to_query

    # query geocoder and make sure it responds quickly
    begin
      resp = nil
      timeout(3) do
        Net::HTTP.get_response(URI.parse(url)).body
      end
    rescue SocketError, TimeoutError
      return nil
    end
  end

  ##
  # Calculate the distance between two points on Earth (Haversine formula).
  # Takes two sets of coordinates and an options hash:
  #
  # <tt>:units</tt> :: <tt>:mi</tt> (default) or <tt>:km</tt>
  #
  def self.distance_between(lat1, lon1, lat2, lon2, options = {})

    # set default options
    options[:units] ||= :mi

    # define conversion factors
    conversions = { :mi => 3956, :km => 6371 }

    # convert degrees to radians
    lat1 = to_radians(lat1)
    lon1 = to_radians(lon1)
    lat2 = to_radians(lat2)
    lon2 = to_radians(lon2)

    # compute distances
    dlat = (lat1 - lat2).abs
    dlon = (lon1 - lon2).abs

    a = (Math.sin(dlat / 2))**2 + Math.cos(lat1) *
        (Math.sin(dlon / 2))**2 * Math.cos(lat2)
    c = 2 * Math.atan2( Math.sqrt(a), Math.sqrt(1-a))
    c * conversions[options[:units]]
  end

  ##
  # Convert degrees to radians.
  #
  def self.to_radians(degrees)
    degrees * (Math::PI / 180)
  end

end
