class Listing::Search::Area < Struct.new(:center, :bounds, :radius, :address_components)
  delegate :distance_from, :radians, to: :center

  def fetch_address_component(name)
    address_components.fetch_address_component(name)
  end
end
