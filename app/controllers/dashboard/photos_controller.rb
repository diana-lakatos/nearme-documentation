class Dashboard::PhotosController < Dashboard::BaseController
  before_filter :get_proper_hash, :only => [:create]

  def create
    @photo = Photo.new
    @photo.owner = @owner
    @photo.owner_type ||= @owner_type
    @photo.image = @image
    @photo.creator_id = current_user.id
    if @photo.save
      render :text => {
        :id => @photo.id,
        :transactable_id => @photo.owner_id,
        :thumbnail_dimensions => 'Project' === @owner_type ? @photo.image.thumbnail_dimensions[:project_thumbnail] : @photo.image.thumbnail_dimensions[:medium],
        :url => 'Project' === @owner_type ? @photo.image_url(:project_thumbnail) : @photo.image_url(:medium) ,
        :destroy_url => destroy_space_wizard_photo_path(@photo),
        :resize_url =>  edit_dashboard_photo_path(@photo)
      }.to_json,
      :content_type => 'text/plain'
    else
      render :text => [{:error => @photo.errors.full_messages}], :content_type => 'text/plain', :status => 422
    end
  end

  def edit
    @photo = current_user.photos.find(params[:id])
    if request.xhr?
      render partial: 'dashboard/photos/resize_form', :locals => { :form_url => dashboard_photo_path(@photo), :object => @photo.image, :object_url => @photo.image_url(:original) }
    end
  end

  def update
    @photo = current_user.photos.find(params[:id])
    @photo.image_transformation_data = { :crop => params[:crop], :rotate => params[:rotate] }
    if @photo.save
      render partial: 'dashboard/photos/resize_succeeded'
    else
      render partial: 'dashboard/photos/resize_form', :locals => { :form_url => dashboard_photo_path(@photo), :object => @photo.image, :object_url => @photo.image_url(:original) }
    end
  end

  def destroy
    @photo = current_user.photos.find(params[:id])
    if @photo.destroy
      render :text => { success: true, id: @photo.id }, :content_type => 'text/plain'
    else
      render :text => { :errors => @photo.errors.full_messages }, :status => 422, :content_type => 'text/plain'
    end
  end


  private
  # TODO: this is so ugly - just make a common standard, and that's it
  def get_proper_hash
    # we came from list your space flow
    if params[:listing]
      photo_params = params[:listing]
      @owner = current_user.listings.find(params[:listing][:id]) if params[:listing][:id].present?
    elsif params[:project]
      @owner_type = 'Project'
      photo_params = params[:project]
      @owner = current_user.projects.find(params[:project][:id]) if params[:project][:id].present?
    elsif params[:transactable]
      photo_params = params[:transactable]
      @owner = current_user.listings.find(params[:transactable][:id]) if params[:transactable][:id].present?
    elsif params[:user] && params[:user][:companies_attributes]
      photo_params = params[:user][:companies_attributes]["0"][:locations_attributes]["0"][:listings_attributes]["0"]
      @owner = current_user.listings.find(photo_params[:id]) if photo_params[:id]
      # we came from dashboard
    elsif params[:user] && params[:user][:projects_attributes]
      @owner_type = 'Project'
      photo_params = params[:user][:projects_attributes]["0"]
      @owner = current_user.projects.find(photo_params[:id]) if photo_params[:id]
    end
    @owner_type = @owner.try(:class).try(:name) if @owner
    @owner_type ||= 'Transactable'
    @image = photo_params[:photos_attributes]["0"][:image]
  end

end
