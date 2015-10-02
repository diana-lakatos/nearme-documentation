class InstanceAdmin::Projects::SpamReportsController < InstanceAdmin::Projects::BaseController
  def index
    @spam_reports = SpamReport.all
  end

  def destroy
    SpamReport.find(params[:id]).spamable.destroy
    redirect_to :back
  end
end
