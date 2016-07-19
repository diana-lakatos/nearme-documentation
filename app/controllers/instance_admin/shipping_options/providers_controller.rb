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
      create_shippo_profiles
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

  def create_shippo_profiles
    ShippingProfile.where(shipping_type: 'shippo_one_way', user_id: current_user.id, global: true).first_or_create do |sp|
      sp.name = 'Delivery with Shippo'
      sp.shipping_rules.build(name: 'Pick up', price_cents: 0, processing_time: 0, is_pickup: true)
      sp.shipping_rules.build(name: 'Delivery', price_cents: 0, processing_time: 0, use_shippo_for_price: true)
    end
    ShippingProfile.where(shipping_type: 'shippo_return', user_id: current_user.id, global: true).first_or_create do |sp|
      sp.name = 'Rental with Shippo'
      sp.shipping_rules.build(name: 'Pick up', price_cents: 0, processing_time: 0, is_pickup: true)
      sp.shipping_rules.build(name: 'Delivery & Return', price_cents: 0, processing_time: 0, use_shippo_for_price: true)
    end
  end

end
