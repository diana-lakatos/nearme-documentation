class InstanceAdmin::BuySell::ZonesController < InstanceAdmin::BuySell::BaseController

  def index
    @zones = zone_scope.all
  end

  def new
    @zone = zone_scope.new
  end

  def create
    @zone = zone_scope.new(zone_params)
    if @zone.save
      flash[:success] = t('flash_messages.buy_sell.zone_added')
      redirect_to instance_admin_buy_sell_zones_path
    else
      render :new
    end
  end

  def edit
    @zone = zone_scope.find(params[:id])
  end

  def update
    @zone = zone_scope.find(params[:id])
    if @zone.update_attributes(zone_params)
      flash[:success] = t('flash_messages.buy_sell.zone_updated')
      redirect_to instance_admin_buy_sell_zones_path
    else
      render 'edit'
    end
  end

  def destroy
    @zone = zone_scope.find(params[:id])
    @zone.destroy
    flash[:success] = t('flash_messages.buy_sell.zone_deleted')
    redirect_to instance_admin_buy_sell_zones_path
  end

  private

  def zone_scope
    Spree::Zone
  end

  def zone_params
    params.require(:zone).permit(secured_params.zone)
  end
end
