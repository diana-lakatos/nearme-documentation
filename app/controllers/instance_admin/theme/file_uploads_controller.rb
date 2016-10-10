class InstanceAdmin::Theme::FileUploadsController < InstanceAdmin::Theme::BaseController

  def index
    @files = Ckeditor::Asset.where(assetable: PlatformContext.current.instance).order(:id => :desc)
    @files = Ckeditor::Paginatable.new(@files).page(params[:page])
    @file = Ckeditor::Asset.new
  end

  def create
    params[:upload][:file] ||= params[:upload][:data] if params[:upload] # compatibility hack
    if params[:upload] && params[:upload][:file]
      if params[:upload][:file].content_type.to_s.match(/^image\/(?!svg)/i)
        @file = Ckeditor.picture_model.new
      else
        @file = Ckeditor.attachment_file_model.new
      end

      file = params[:upload][:file]
      @file.title = params[:upload][:title]
      @file.access_level = params[:upload][:access_level]
      @file.data = Ckeditor::Http.normalize_param(file, request)
      @file.assetable = PlatformContext.current.instance

      if request.xhr?
        if @file.save
          render(partial: 'asset', locals: { asset: @file })
        else
          render text: I18n.t('flash_messages.instance_admin.theme.file_uploads.failed', errors: @file.errors.full_messages.join(', '))
        end
      else
        if @file.save
          flash[:notice] = I18n.t('flash_messages.instance_admin.theme.file_uploads.created')
          redirect_to instance_admin_theme_file_uploads_path
        else
          @files = Ckeditor::Asset.where(assetable: PlatformContext.current.instance).order(:id => :desc)
          @files = Ckeditor::Paginatable.new(@files).page(params[:page])
          flash[:error] = I18n.t('flash_messages.instance_admin.theme.file_uploads.failed', errors: @file.errors.full_messages.join(', '))
          render :index
        end
      end
    else
      if request.xhr?
        render text: I18n.t('flash_messages.instance_admin.theme.file_uploads.failed', errors: @file.errors.full_messages.join(', '))
      else
        @files = Ckeditor::Asset.where(assetable: PlatformContext.current.instance).order(:id => :desc)
        @files = Ckeditor::Paginatable.new(@files).page(params[:page])
        flash[:error] = 'Please attach file.'
        render action: :index
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

