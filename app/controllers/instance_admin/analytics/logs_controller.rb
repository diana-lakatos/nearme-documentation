class InstanceAdmin::Analytics::LogsController < InstanceAdmin::Analytics::BaseController

  def index
    @logs = MarketplaceError.select('error_type', 'message', 'count(*) count',
      "MAX(created_at) last_occurence", 'MAX(id) id').group(:error_type, :message, :instance_id).
      order("last_occurence DESC").paginate(page: params[:page], per_page: 10)
  end

  def destroy
    @marketplace_error = MarketplaceError.find(params[:id])

    MarketplaceError.destroy_all(
      error_type: @marketplace_error.error_type,
      message: @marketplace_error.message
    )

    flash[:success] = t('flash_messages.instance_admin.analytics.logs.deleted')
    redirect_to instance_admin_analytics_logs_path
  end

  def show
    @marketplace_error = MarketplaceError.find(params[:id])
    @marketplace_errors = MarketplaceError.where(
      error_type: @marketplace_error.error_type,
      message: @marketplace_error.message
    ).order("created_at DESC").paginate(page: params[:page], per_page: 1)
  end

end

