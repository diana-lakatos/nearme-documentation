class Manage::TransactableTypes::DataUploadsController < Manage::BaseController

  before_filter :find_company
  before_filter :find_transactable_type

  def index
    @data_uploads = @company.data_uploads.for_transactable_type(@transactable_type).order('created_at DESC').paginate(page: params[:page], per_page: 20)
  end

  def create
    @data_upload = @company.data_uploads.build(data_upload_params)
    @data_upload.transactable_type = @transactable_type
    @data_upload.send_invitational_email = @data_upload.send_invitational_email == "1" ? "true" : "false"
    @data_upload.sync_mode = @data_upload.sync_mode == "1" ? "true" : "false"
    @data_upload.uploader_id = current_user.id
    if @data_upload.save
      DataUploadHostConvertJob.perform(@data_upload.id)
      flash[:success] = t 'flash_messages.manage.data_upload.created'
      redirect_to edit_manage_transactable_type_data_upload_path(@transactable_type, @data_upload)
    else
      flash[:error] = @data_upload.errors.full_messages.to_sentence
      render action: :new
    end
  end

  def new
    @data_upload = @company.data_uploads.build
    @data_upload.transactable_type = @transactable_type
  end

  def edit
    @data_upload = @company.data_uploads.for_transactable_type(@transactable_type).find(params[:id])
  end

  def destroy
    @data_upload = @company.data_uploads.for_transactable_type(@transactable_type).find(params[:id])
    @data_upload.destroy
    flash[:deleted] = t('flash_messages.manage.data_upload.deleted')
    redirect_to manage_transactable_type_data_uploads_path
  end

  def schedule_import
    @data_upload = @company.data_uploads.for_transactable_type(@transactable_type).find(params[:id])
    if @data_upload.imported_at.nil?
      @data_upload.touch(:imported_at)
      DataUploadImportJob.perform(@data_upload.id)
      flash[:success] = t('flash_messages.manage.data_upload.scheduled')
    else
      flash[:error] =t('flash_messages.manage.data_upload.not_scheduled')
    end
    redirect_to manage_transactable_type_data_uploads_path(@transactable_type)
  end

  def download_csv_template
    send_data DataImporter::Host::CsvTemplateGenerator.new(@transactable_type).generate_template, filename: "csv_template.csv"
  end

  def download_current_data_csv
    send_data DataImporter::Host::CsvCurrentDataGenerator.new(current_user, @transactable_type).generate_csv, filename: "data.csv"
  end

  private

  def find_transactable_type
    @transactable_type = TransactableType.find(params[:transactable_type_id])
  end

  def data_upload_params
    params.require(:data_upload).permit(secured_params.data_upload)
  end

  def find_company
    @company = current_user.companies.first
  end
end

