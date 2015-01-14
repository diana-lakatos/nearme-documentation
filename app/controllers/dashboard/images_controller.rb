class Dashboard::ImagesController < Dashboard::BaseController

  before_filter :find_product, only: [:create]
  before_filter :find_image, only: [:edit, :update, :destroy]

  def create
    if @product.present?
      @image = @product.images.build
      @image.uploader_id = current_user.id
    else
      @image = current_user.products_images.build
    end
    @image.image_original_url = @image_url
    if @image.save
      render :text => {
        :id => @image.id,
        :transactable_id => @image.viewable_id,
        :thumbnail_dimensions => @image.image.thumbnail_dimensions[:medium],
        :url => @image.image_url(:medium),
        :destroy_url => dashboard_image_path(@image),
        :resize_url =>  edit_dashboard_image_path(@image)
      }.to_json,
      :content_type => 'text/plain'
    else
      render :text => [{:error => @image.errors.full_messages}], :content_type => 'text/plain', :status => 422
    end
  end

  def edit
  end

  def update
    @image.image_transformation_data = { :crop => params[:crop], :rotate => params[:rotate] }
    if @image.save
    else
      render :edit
    end
  end

  def destroy

    if @image.destroy
      render :text => { success: true, id: @image.id }, :content_type => 'text/plain'
    else
      render :text => { :errors => @image.errors.full_messages }, :status => 422, :content_type => 'text/plain'
    end
  end


  private

  def find_product
    @product = @company.products.with_deleted.find(params[:product_id]) if params[:product_id].present?
    @image_url = params[:product_form][:images_attributes]["0"][:image]
  end

  def find_image
    @image = @company.products_images.find_by_id(params[:id])
    @image ||= current_user.products_images.find(params[:id])
  end

end
