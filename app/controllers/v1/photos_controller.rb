class V1::PhotosController <  V1::BaseController
  before_filter :verify_authenticity_token
  before_filter :require_authentication
  before_filter :find_photo, :except => [:create]

  def create
    @photo = Photo.create(params)
    @photo.creator_id = current_user.id
    if @photo.save
       if params[:photouploader]
         photo_json_hash = ActiveSupport::JSON.decode PhotoSerializer.new(@photo).to_json
         render :text => photo_json_hash["photo"].to_json, :root => false, :content_type => 'text/plain'
       else
         render :json => @photo, :root => false
       end
    else
      if params[:photouploader]
        render :text => [{:error => @photo.errors.full_messages}].to_json, :status => 422, :content_type => 'text/plain'
      else
        render :json => [{:error => @photo.errors.full_messages}], :status => 422
      end
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
      @photo = current_user.photos.find(params[:id])
    end
end
