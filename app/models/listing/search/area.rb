class Listing::Search::Area < Struct.new(:center, :bounds, :radius, :address_components)
  delegate :distance_from, :radians, to: :center

  def fetch_address_component(name, name_type = :long)
    address_components.fetch_address_component(name, name_type)
  end
end
