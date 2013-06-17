class Listing::Search::Area < Struct.new(:center, :bounds, :radius, :address_components)
  delegate :distance_from, :radians, to: :center
end
