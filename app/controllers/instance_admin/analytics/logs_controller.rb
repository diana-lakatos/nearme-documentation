class InstanceAdmin::Analytics::LogsController < InstanceAdmin::Analytics::BaseController

  def index
    @logs = MarketplaceError.order('created_at DESC').paginate(page: params[:page])
  end

  def destroy
    @marketplace_error = MarketplaceError.find(params[:id])
    @marketplace_error.destroy
    flash[:success] = t('flash_messages.instance_admin.analytics.logs.deleted')
    redirect_to instance_admin_analytics_logs_path
  end

end

