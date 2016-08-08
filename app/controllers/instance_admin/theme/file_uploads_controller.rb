class InstanceAdmin::Theme::FileUploadsController < InstanceAdmin::Theme::BaseController

  def index
    @files = Ckeditor::Asset.where(assetable: PlatformContext.current.instance).order(:id => :desc)
    @files = Ckeditor::Paginatable.new(@files).page(params[:page])
  end

  def create
    if params[:upload] && params[:upload][:file]
      if params[:upload][:file].content_type.to_s.match(/^image\/(?!svg)/i)
        @attachment = Ckeditor.picture_model.new
      else
        @attachment = Ckeditor.attachment_file_model.new
      end

      file = params[:upload][:file]
      @attachment.data = Ckeditor::Http.normalize_param(file, request)
      @attachment.assetable = PlatformContext.current.instance

      if @attachment.save
        render(partial: 'asset', locals: { asset: @attachment })
      else
        render text: I18n.t('flash_messages.instance_admin.theme.file_uploads.failed', errors: @attachment.errors.full_messages.join(', '))
      end
    end
  end

  def search
    @query = params[:search][:query] if params[:search] && params[:search][:query]
    escaped_search_param = ActiveRecord::Base.connection.quote_like_string(@query.to_s)
    @files = Ckeditor::Asset.where(assetable: PlatformContext.current.instance).where("data_file_name ILIKE ?", "%#{escaped_search_param}%").order(:id => :desc)
    @files = Ckeditor::Paginatable.new(@files).page(params[:page])

    render 'index'
  end

  def destroy
    @file = Ckeditor::Asset.where(assetable: PlatformContext.current.instance, id: params[:id]).first
    @file.try(:destroy)

    respond_to do |format|
        format.js {
          render :text => %Q"
              jQuery('#picture_#{@file.try(:id)}').remove();
              jQuery('#attachment_file_#{@file.try(:id)}').remove();
            "
        }
    end
  end

end

