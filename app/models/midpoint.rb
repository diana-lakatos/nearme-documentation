class Midpoint
  attr :center
  delegate :radians, :distance_from, to: :center
  def initialize(*points)
    points.map!(&:to_f)
    points = points.size == 2 ? [points.first.to_a, points.last.to_a] : points.each_slice(2).to_a
    lat, long = Geocoder::Calculations.geographic_center(points)
    @center =  Coordinate.new(lat, long)
  end
end
