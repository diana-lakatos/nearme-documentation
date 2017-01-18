class InstanceAdmin::Manage::InappropriateReportsController < InstanceAdmin::Manage::BaseController

  def index
    @inappropriate_reports = InappropriateReport.order('created_at DESC').paginate(page: params[:page])
  end

  def destroy
    @inappropriate_report = InappropriateReport.find(params[:id])
    @inappropriate_report.destroy

    redirect_to [:instance_admin, :manage, :inappropriate_reports]
  end

end
