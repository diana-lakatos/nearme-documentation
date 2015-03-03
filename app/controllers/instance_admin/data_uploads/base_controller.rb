class InstanceAdmin::DataUploads::BaseController < InstanceAdmin::BaseController

  before_filter :find_importable
  before_filter :set_import_job, only: :create

  def new
    @data_upload = DataUpload.new
  end

  def index
    @data_uploads = PlatformContext.current.instance.data_uploads.for_importable(@importable).all
  end

  def create
    @data_upload = PlatformContext.current.instance.data_uploads.build(data_upload_params)
    if @data_upload.save
      @import_job.perform(@data_upload.id)
      flash[:success] = t 'flash_messages.instance_admin.data_uploads.created'
      redirect_to action: :show, id: @data_upload
    else
      flash[:error] = @data_upload.errors.full_messages.to_sentence
      render action: :new
    end
  end

  def show
    @data_upload = PlatformContext.current.instance.data_uploads.for_importable(@importable).find(params[:id])
  end

  def download_csv_template
    send_data DataImporter::CsvTemplateGenerator.new(@importable).generate,
      filename: "#{@importable.name.parameterize}_csv_template.csv"
  end

  private

  def data_upload_params
    params[:data_upload][:options] ||= {}
    params[:data_upload][:options][:sync_mode] = '0'
    params.require(:data_upload).permit(secured_params.data_upload).merge(uploader: current_user, importable: @importable)
  end
end