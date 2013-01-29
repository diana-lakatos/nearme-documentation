class V1::LocationsController <  V1::BaseController
  skip_before_filter :verify_authenticity_token, :only => [:create, :update, :destroy]
  before_filter :require_authentication
  before_filter :find_location, only: [:update, :destroy]

  expose :location

  def list
    @locations = current_user.default_company.locations
  end

  def create
    @location = Location.create(params[:location])
    @location.company_id = current_user.default_company.id
    if @location.save
      render :json => {:success => true, :id => @location.id}
    else
      render :json => { :errors => @location.errors.full_messages }, :status => 422
    end
  end

  def update
    @location.attributes = params[:location]
    if @location.save
      render json: { success: true, id: @location.id }
    else
      render :json => { :errors => @location.errors.full_messages }, :status => 422
    end
  end


  def destroy
    if @location.destroy
      render json: { success: true, id: @location.id }
    else
      render :json => { :errors => @location.errors.full_messages }, :status => 422
    end
  end

  private
    def find_location
      @location = current_user.locations.find(params[:id])
    end

end
