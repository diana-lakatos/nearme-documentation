class Dashboard::DataUploads::BaseController < Dashboard::BaseController
  before_filter :find_importable
  before_filter :set_import_job, only: :create

  def new
    @data_upload = @company.data_uploads.build
    @data_upload.importable = @importable
    render partial: 'form'
  end

  def create
    @data_upload = @company.data_uploads.build(data_upload_params)
    if @data_upload.save
      @import_job.perform(@data_upload.id)
      flash[:success] = t 'flash_messages.manage.data_upload.created'
    else
      flash[:error] = @data_upload.errors.full_messages.to_sentence
    end
    redirect_to after_import_redirect_path
  end

  def download_csv_template
    send_data DataImporter::Host::CsvTemplateGenerator.new(@importable).generate,
              filename: "#{@importable.name.parameterize}_csv_template.csv"
  end

  def data_upload_params
    params[:data_upload][:options] ||= {}
    params[:data_upload][:options][:send_invitational_email] = '0'
    params.require(:data_upload).permit(secured_params.data_upload).merge(uploader: current_user, importable: @importable)
  end
end
