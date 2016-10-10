class Dashboard::Company::TransactableTypes::DataUploadsController < Dashboard::DataUploads::BaseController
  def download_current_data_csv
    send_data DataImporter::Host::CsvCurrentDataGenerator.new(current_user, @importable).generate_csv, filename: 'data.csv'
  end

  private

  def set_import_job
    @import_job = DataUploadHostConvertJob
  end

  def find_importable
    @importable = TransactableType.find(params[:transactable_type_id])
  end

  def after_import_redirect_path
    dashboard_company_transactable_type_transactables_path(@importable)
  end
end
