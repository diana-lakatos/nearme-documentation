class Dashboard::TransactableTypes::DataUploadsController < Dashboard::BaseController

  before_filter :find_transactable_type

  def index
    @data_uploads = @company.data_uploads.for_transactable_type(@transactable_type).order('created_at DESC').paginate(page: params[:page], per_page: 20)
  end

  def show
    if request.xhr?
      render partial: 'manage/transactable_types/data_uploads/data_upload', :locals => { data_upload: @company.data_uploads.for_transactable_type(@transactable_type).find(params[:id]) }
    end
  end

  def create
    @data_upload = @company.data_uploads.build(data_upload_params)
    lines_count = 0
    File.foreach(@data_upload.csv_file.path) { |line| lines_count += 1 }
    if lines_count < 5000
      @data_upload.transactable_type = @transactable_type
      @data_upload.send_invitational_email = "0"
      @data_upload.uploader_id = current_user.id
      if @data_upload.save
        DataUploadHostConvertJob.perform(@data_upload.id)
        flash[:success] = t 'flash_messages.manage.data_upload.created'
        redirect_to edit_manage_transactable_type_data_upload_path(@transactable_type, @data_upload)
      else
        flash[:error] = @data_upload.errors.full_messages.to_sentence
        render action: :new
      end
    else
      flash[:error] = t 'flash_messages.manage.data_upload.too_many_rows', max: 5000
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

  def status
    render json: @company.data_uploads.for_transactable_type(@transactable_type).where(id: params[:ids]).pluck(:id, :state, :progress_percentage).to_json
  end

  def schedule_import
    @data_upload = @company.data_uploads.for_transactable_type(@transactable_type).find(params[:id])
    if @data_upload.waiting?
      @data_upload.queue!
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

