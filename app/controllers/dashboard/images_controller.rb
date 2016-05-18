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
    @image.image = @image_data
    if @image.save

      sizes = {}
      @image.image.thumbnail_dimensions.each_with_index do |dimensions, index|
        sizes[dimensions[0]] = { width: dimensions[1][:width], height: dimensions[1][:height], url: @image.image_url(dimensions[0].to_sym) }
      end

      sizes[:full] = { url: @image.image_url }

      render :text => {
        :id => @image.id,
        :transactable_id => @image.viewable_id,
        :thumbnail_dimensions => @image.image.thumbnail_dimensions[:medium],
        :url => @image.image_url(:medium),
        :destroy_url => dashboard_image_path(@image),
        :resize_url =>  edit_dashboard_image_path(@image),
        :sizes => sizes
      }.to_json,
      :content_type => 'text/plain'
    else
      render :text => [{:error => @image.errors.full_messages}], :content_type => 'text/plain', :status => 422
    end
  end

  def edit
    if request.xhr?
      render partial: "dashboard/photos/resize_form", locals: { form_url: dashboard_image_path(@image), object: @image.image, object_url: @image.image_url(:original) }
    end
  end

  def update
    @image.image_transformation_data = { crop: params[:crop], rotate: params[:rotate] }
    if @image.save
      render partial: 'dashboard/photos/resize_succeeded'
    else
      render partial: "dashboard/photos/resize_form", locals: { form_url: dashboard_image_path(@image), object: @image.image, object_url: @image.image_url(:original) }
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
    @product = @company.products.with_deleted.find(params[:product_id]) if params[:product_id].present? if @company.present?
    if params[:product_form]
      @image_data = params[:product_form][:images_attributes]["0"][:image]
    elsif params[:boarding_form]
      @image_data = params[:boarding_form][:product_form][:images_attributes]["0"][:image]
    else
      raise NotImplementedError
    end
  end

  def find_image
    @image = @company.products_images.find_by_id(params[:id]) if @company.present?
    @image ||= current_user.products_images.find(params[:id])
  end

end
