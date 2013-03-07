class Listing::Search::Area < Struct.new(:center, :bounds, :radius)
  delegate :distance_from, :radians, to: :center
end
