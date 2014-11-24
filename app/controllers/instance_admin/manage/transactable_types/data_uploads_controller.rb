class InstanceAdmin::Manage::TransactableTypes::DataUploadsController < InstanceAdmin::Manage::BaseController

  before_filter :find_transactable_type

  def index
    @data_uploads = PlatformContext.current.instance.data_uploads.for_transactable_type(@transactable_type).all
  end

  def create
    @data_upload = PlatformContext.current.instance.data_uploads.build(data_upload_params)
    @data_upload.transactable_type = @transactable_type
    @data_upload.uploader_id = current_user.id
    @data_upload.sync_mode = "0"
    if @data_upload.save
      DataUploadConvertJob.perform(@data_upload.id)
      flash[:success] = t 'flash_messages.instance_admin.manage.data_upload.created'
      redirect_to edit_instance_admin_manage_transactable_type_data_upload_path(@transactable_type, @data_upload)
    else
      flash[:error] = @data_upload.errors.full_messages.to_sentence
      render action: :new
    end
  end

  def edit
    @data_upload = PlatformContext.current.instance.data_uploads.for_transactable_type(@transactable_type).find(params[:id])
  end

  def update
    @data_upload = PlatformContext.current.instance.data_uploads.for_transactable_type(@transactable_type).find(params[:id])
  end

  def schedule_import
    @data_upload = PlatformContext.current.instance.data_uploads.for_transactable_type(@transactable_type).find(params[:id])
    if @data_upload.imported_at.nil?
      DataUploadImportJob.perform(@data_upload.id)
      @data_upload.touch(:imported_at)
      flash[:success] = 'Data has been scheduled to be imported.'
    else
      flash[:error] = "This data has been already imported."
    end
    redirect_to instance_admin_manage_transactable_type_data_uploads_path(@transactable_type)
  end

  def download_csv_template
    send_data DataImporter::CsvTemplateGenerator.new(@transactable_type).generate_template, filename: "#{PlatformContext.current.instance.name}_csv_template.csv"
  end

  private

  def find_transactable_type
    @transactable_type = TransactableType.find(params[:transactable_type_id])
  end

  def permitting_controller_class
    'manage'
  end

  def data_upload_params
    params.require(:data_upload).permit(secured_params.data_upload)
  end
end
