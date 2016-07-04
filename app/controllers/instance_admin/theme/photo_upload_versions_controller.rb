class InstanceAdmin::Theme::PhotoUploadVersionsController < InstanceAdmin::Theme::BaseController

  before_filter :set_breadcrumbs_title

  def index
    @photo_upload_versions = @theme.photo_upload_versions
  end

  def show
  end

  def new
    @photo_upload_version = PhotoUploadVersion.new
  end

  def create
    @photo_upload_version = PhotoUploadVersion.new
    @photo_upload_version.assign_attributes(photo_upload_version_params)
    @photo_upload_version.theme = @theme

    if @photo_upload_version.save
      flash[:success] = t('instance_admin.theme.photo_upload_versions.create_success')
      redirect_to instance_admin_theme_photo_upload_versions_path
    else
      flash.now[:error] = t('instance_admin.theme.photo_upload_versions.create_error')
      render :new
    end
  end

  def edit
    @photo_upload_version = @theme.photo_upload_versions.find(params[:id])
  end

  def update
    @photo_upload_version = @theme.photo_upload_versions.find(params[:id])

    if @photo_upload_version.update_attributes(photo_upload_version_params)
      flash[:success] = t('instance_admin.theme.photo_upload_versions.update_success')
      redirect_to instance_admin_theme_photo_upload_versions_path
    else
      flash.now[:error] = t('instance_admin.theme.photo_upload_versions.update_error')
      render :edit
    end
  end

  def regenerate_versions
    uploader_name = params[:regenerate_upload][:uploader_name]

    if uploader_name.present?
      if PhotoUploadVersion.can_regenerate_for_uploader?(uploader_name)
        flash[:success] = t('instance_admin.theme.photo_upload_versions.image_regeneration_scheduled')
    
        ScheduledUploadersRegeneration.create(photo_uploader: uploader_name)
        RegenerateUploaderVersionsJob.perform(uploader_name)

        redirect_to instance_admin_theme_photo_upload_versions_path
      else
        flash[:error] = t('instance_admin.theme.photo_upload_versions.already_scheduled')
        redirect_to instance_admin_theme_photo_upload_versions_path
      end
    else
      flash[:error] = t('instance_admin.theme.photo_upload_versions.please_specify_uploader_name')
      redirect_to instance_admin_theme_photo_upload_versions_path
    end
  end

  def set_breadcrumbs_title
    @breadcrumbs_title = BreadcrumbsList.new(
      { :title => t('instance_admin.general.manage') },
      { :title => t('instance_admin.theme.photo_upload_versions.title') }
    )
  end

  def photo_upload_version_params
    params.require(:photo_upload_version).permit(secured_params.photo_upload_version)
  end

end
