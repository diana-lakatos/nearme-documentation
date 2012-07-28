class V1::AmenitiesController < V1::BaseController
  def index
    render json: Amenity.all
  end
end
