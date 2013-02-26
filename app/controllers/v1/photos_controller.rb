class V1::PhotosController <  V1::BaseController
  before_filter :verify_authenticity_token
  before_filter :require_authentication
  before_filter :find_photo, :except => [:create]

  def create
    @photo = Photo.create(params)
    if @photo.save
       render :json => @photo, :root => false
    else
      render :json => [{:error => @photo.errors.full_messages}], :status => 422
    end
  end

  def destroy
    if @photo.destroy
      render json: { success: true, id: @photo.id }
    else
      render :json => { :errors => @photo.errors.full_messages }, :status => 422
    end
  end

  private
    def find_photo
      @photo = Photo.find(params[:id])
    end
end
