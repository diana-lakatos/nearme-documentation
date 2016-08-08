class InstanceAdmin::Theme::DefaultImagesController < InstanceAdmin::Theme::BaseController

  def index
    @default_images = PlatformContext.current.theme.default_images
  end

  def new
    @default_image = DefaultImage.new
  end

  def create
    @default_image = DefaultImage.new(default_image_params)
    @default_image.theme = PlatformContext.current.theme

    # We assign this as a second step to ensure we have all fields
    # assigned when we hit the resize method in DefaultImageUploader
    @default_image.photo_uploader_image = params[:default_image][:photo_uploader_image]

    if @default_image.save
      redirect_to instance_admin_theme_default_images_path
    else
      render :new
    end
  end

  def destroy
    @default_image = PlatformContext.current.theme.default_images.find(params[:id])
    @default_image.destroy

    redirect_to instance_admin_theme_default_images_path
  end

  protected

  def default_image_params
    params.require(:default_image).permit(secured_params.default_image)
  end

end

