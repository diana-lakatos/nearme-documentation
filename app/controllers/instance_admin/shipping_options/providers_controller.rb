class InstanceAdmin::ShippingOptions::ProvidersController < InstanceAdmin::ShippingOptions::BaseController
  before_filter :load_instance
  before_filter :set_breadcrumbs

  def show
    redirect_to edit_instance_admin_shipping_options_providers_path
  end

  def edit
  end

  def update
    if ShippoApi::ShippoApi.verify_connection(instance_params) && @instance.update_attributes(instance_params)
      flash[:success] = t('flash_messages.shipping_options.shipping_providers.options_updated')
      redirect_to instance_admin_shipping_options_providers_path
    else
      flash[:error] = t('flash_messages.shipping_options.shipping_providers.options_not_updated')
      render 'edit'
    end
  end

  private

  def set_breadcrumbs
    @breadcrumbs_title = 'Manage Providers'
  end

  def load_instance
    @instance = platform_context.instance
  end

  def instance_params
    params.require(:instance).permit(secured_params.instance_shipping_providers)
  end

end
