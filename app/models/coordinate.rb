require 'geocoder'

class Coordinate < Struct.new(:lat, :long)
  def initialize(lat, long)
    super lat.to_f, long.to_f
  end
  
  def radians
    @radians ||= Geocoder::Calculations.to_radians(to_a)
  end

  def distance_from(*coordinate)
    coordinate = coordinate.size == 1 ? coordinate.first : Coordinate.new(*coordinate)
    (Geocoder::Calculations.distance_between(coordinate.to_a, to_a, :units => :km) * 1_000).to_f
  end

end
