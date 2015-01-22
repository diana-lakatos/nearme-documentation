class InstanceAdmin::BuySell::CommissionsController < InstanceAdmin::BuySell::BaseController
  before_action :find_instance

  def show
  end

  def update
    if @instance.update_attributes(instance_params)
      flash.now[:success] = t('flash_messages.buy_sell.commissions_saved_successful')
      render :show
    else
      flash.now[:error] = @instance.errors.full_messages.to_sentence
      render :show
    end
  end

  protected

  def find_instance
    @instance = platform_context.instance
  end

  def instance_params
    params.require(:instance).permit(secured_params.instance)
  end

end

