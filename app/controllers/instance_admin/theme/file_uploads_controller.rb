class InstanceAdmin::Theme::FileUploadsController < InstanceAdmin::Theme::BaseController

  def index
    @files = Ckeditor::Asset.where(assetable: PlatformContext.current.instance).order(:id => :desc)
    @files = Ckeditor::Paginatable.new(@files).page(params[:page])
  end

  def create
    if params[:upload] && params[:upload][:file]
      if params[:upload][:file].content_type.to_s.match(/^image/i)
        @attachment = Ckeditor.picture_model.new
      else
        @attachment = Ckeditor.attachment_file_model.new
      end

      file = params[:upload][:file]
      @attachment.data = Ckeditor::Http.normalize_param(file, request)
      @attachment.assetable = PlatformContext.current.instance

      if @attachment.save
        flash[:success] = 'File uploaded successfully'
      else
        flash[:error] = 'File upload failed'
      end
    else
        flash[:error] = 'File upload failed'
    end

    redirect_to instance_admin_theme_file_uploads_path
  end

  def destroy
    @file = Ckeditor::Asset.where(assetable: PlatformContext.current.instance, id: params[:id]).first
    @file.destroy

    redirect_to instance_admin_theme_file_uploads_path
  end

end

