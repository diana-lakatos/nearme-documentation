class V1::AmenitiesController < V1::BaseController
  def index
    @amenities = Amenity.joins(:amenity_type).where(amenity_types: {instance_id: 1})
    render json: {"amenities" => @amenities}, root: false
  end
end
