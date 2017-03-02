class InstanceAdmin::Manage::MarketplaceBuilderController < InstanceAdmin::Manage::BaseController
  def index
  end

  def import
    InstanceAdmin::Manage::MarketplaceBuilderImportService.new(params[:marketplace_builder][:zip_file]).call
    redirect_to :back
  rescue StandardError => e
    redirect_to :back, notice: "There was an error while importing: #{e.message}"
  end

  def download_export
    InstanceAdmin::Manage::MarketplaceBuilderExportService.new(method(:send_zip_file)).call
  end

  private

  def send_zip_file(file_stream)
    send_data file_stream.read, type: 'application/zip', filename: File.basename(file_stream.path)
  end
end
