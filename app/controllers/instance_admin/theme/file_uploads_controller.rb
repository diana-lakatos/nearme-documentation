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
        render(partial: 'asset', locals: { asset: @attachment })
      end
    end
  end

  def destroy
    @file = Ckeditor::Asset.where(assetable: PlatformContext.current.instance, id: params[:id]).first
    @file.destroy

    respond_to do |format|
        format.js {
          render :text => %Q"
              jQuery('#picture_#{@file.id}').remove();
              jQuery('#attachment_file_#{@file.id}').remove();
            "
        }
    end
  end

end

