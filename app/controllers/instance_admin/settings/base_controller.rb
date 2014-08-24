class InstanceAdmin::Settings::BaseController < InstanceAdmin::BaseController
  CONTROLLERS = { 'configuration' => { default_action: 'show' },
                  'locations'     => { default_action: 'show' },
                  'listings'      => { default_action: 'show' },
                  'translations'  => { default_action: 'show' },
                  'integrations'  => { default_action: 'show' },
                  'cancellation_policy'  => { default_action: 'show' },
  }

  before_filter :find_instance
  before_filter :find_instance_translations

  def index
    redirect_to instance_admin_settings_configuration_path
  end

  def show
    find_or_build_billing_gateway_for_usd
  end

  def update
    if params[:instance].present?
      if @instance.update_attributes(instance_params)
        flash.now[:success] = t('flash_messages.instance_admin.settings.settings_updated')
        find_or_build_billing_gateway_for_usd
        render :show
      else
        flash.now[:error] = @instance.errors.full_messages.to_sentence
        find_or_build_billing_gateway_for_usd
        render :show
      end
    else
      find_or_build_billing_gateway_for_usd
      render :show
    end
  end

  private

  def find_or_build_billing_gateway_for_usd
    InstanceBillingGateway.find{|bg| bg.currency == 'USD'} || @instance.instance_billing_gateways.build(currency: 'USD')
  end

  def find_instance
    @instance = platform_context.instance
  end

  def find_instance_translations
    @translations = @instance.translations
  end

  def instance_params
    params.require(:instance).permit(secured_params.instance)
  end
end
