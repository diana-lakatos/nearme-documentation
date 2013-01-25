class V1::LocationsController <  V1::BaseController
  before_filter :require_authentication

  expose :location

  def list
    @locations = current_user.default_company.locations
  end

  def create
    @location = Location.create(params[:location])
    if @location.save
      render :json => {:success => true, :id => @model.id}
    else
      render :json => { :errors => @model.errors.full_messages }, :status => 422
    end
  end

  def destroy
    @location = current_user.locations.find(params[:id])
    if @location.destroy
      render json: { success: true, id: @location.id }
    else
      render :json => { :errors => @model.errors.full_messages }, :status => 422
    end
  end
end
