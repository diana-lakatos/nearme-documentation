class V1::AmenitiesController < V1::BaseController
  def index
    render json: {"amenities" => Amenity.all}, root: false
  end
end
