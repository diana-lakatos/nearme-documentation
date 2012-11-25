class Listing::Search::Area < Struct.new(:center, :radius)
  delegate :distance_from, :radians, to: :center
end
