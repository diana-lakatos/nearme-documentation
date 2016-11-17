# frozen_string_literal: true
class InstanceAdmin::Analytics::LogsController < InstanceAdmin::Analytics::BaseController
  def index
    @logs = MarketplaceErrorGroup.order('last_occurence DESC').paginate(page: params[:page], per_page: 10)
  end

  def destroy
    @marketplace_error_group = MarketplaceErrorGroup.find(params[:id])

    @marketplace_error_group.destroy

    flash[:success] = t('flash_messages.instance_admin.analytics.logs.deleted')
    redirect_to instance_admin_analytics_logs_path
  end

  def show
    @marketplace_error_group = MarketplaceErrorGroup.find(params[:id])
    @marketplace_errors = @marketplace_error_group.marketplace_errors
                                                  .order('created_at DESC').paginate(page: params[:page], per_page: 1)
  end
end
