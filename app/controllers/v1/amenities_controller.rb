class V1::AmenitiesController < V1::BaseController
  def index
    @amenities = Amenity.joins(:amenity_type).where(amenity_types: { instance_id: 1 }).distinct.order('amenities.created_at ASC')
    render json: { 'amenities' => @amenities.uniq }, root: false
  end
end
