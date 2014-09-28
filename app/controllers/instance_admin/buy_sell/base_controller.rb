class InstanceAdmin::BuySell::BaseController < InstanceAdmin::BaseController
  def index
    redirect_to instance_admin_buy_sell_configuration_path
  end
end
