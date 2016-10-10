class V1::LocationsController < V1::BaseController
  before_filter :verify_authenticity_token
  before_filter :require_authentication
  before_filter :find_location, only: [:update, :destroy]

  def list
    @locations = current_user.default_company.locations
    render json: @locations, root: false
  end

  def create
    lat = params[:location].try(:delete, :latitude)
    long = params[:location].try(:delete, :longitude)
    address = params[:location].try(:delete, :address)
    location_address = Address.new(latitude: lat, longitude: long, address: address)
    @location = Location.new(location_params)
    @location.location_address = location_address
    @location.company_id = current_user.default_company.id
    if @location.save
      render json: { success: true, id: @location.id }
    else
      render json: { errors: @location.errors.full_messages }, status: 422
    end
  end

  def update
    @location.assign_attributes(location_params)
    if @location.save
      render json: @location, root: false
    else
      render json: { errors: @location.errors.full_messages }, status: 422
    end
  end

  def destroy
    if @location.destroy
      render json: { success: true, id: @location.id }
    else
      render json: { errors: @location.errors.full_messages }, status: 422
    end
  end

  private

  def find_location
    @location = current_user.locations.find(params[:id])
  end

  def location_params
    params.require(:location).permit(
      :address,
      :description,
      :location_type_id,
      :email,
      :latitude,
      :longitude
    )
  end
end
