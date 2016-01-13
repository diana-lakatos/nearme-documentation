class InstanceAdmin::Settings::DocumentsUploadController < InstanceAdmin::Settings::BaseController
  def new
    @documents_upload = DocumentsUpload.new
  end

  def edit
    @documents_upload = @instance.documents_upload
  end

  def create
    @documents_upload = DocumentsUpload.new documents_upload_params
    @documents_upload.requirement = DocumentsUpload::REQUIREMENTS.first if documents_upload_params[:requirement].blank?
    if @documents_upload.save
      flash[:success] = t('flash_messages.instance_admin.settings.settings_updated')
      redirect_to action: :edit
    else
      flash.now[:error] = @documents_upload.errors.full_messages.to_sentence
      render :new
    end
  end

  def update
    @documents_upload = @instance.documents_upload
    if @documents_upload.update(documents_upload_params)
      flash[:success] = t('flash_messages.instance_admin.settings.settings_updated')
      redirect_to action: :edit
    else
      flash.now[:error] = @documents_upload.errors.full_messages.to_sentence
      render :edit
    end
  end

  def show
    if @instance.documents_upload.present?
      redirect_to action: :edit
    else
      redirect_to action: :new
    end
  end

  private

  def documents_upload_params
    params.require(:documents_upload).permit(secured_params.documents_upload)
  end
end
