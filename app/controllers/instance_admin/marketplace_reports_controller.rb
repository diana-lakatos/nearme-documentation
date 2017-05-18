class InstanceAdmin::MarketplaceReportsController < InstanceAdmin::BaseController
  def show
    marketplace_report = MarketplaceReport.find(params[:id])
    redirect_to marketplace_report.zip_file.url
  end
end
