class InstanceAdmin::SettingsController < InstanceAdmin::BaseController
  before_filter :find_instance

  def show
    @instance
    find_or_build_billing_gateway_for_usd
  end

  def update
    @instance.password_protected = !params[:instance][:password_protected].to_i.zero?
    params[:instance][:marketplace_password] = '' if !@instance.password_protected
    if @instance.update_attributes(params[:instance])
      flash[:success] = t('flash_messages.instance_admin.settings.settings_updated')
      find_or_build_billing_gateway_for_usd
      render :show
    else
      find_or_build_billing_gateway_for_usd
      render :show
    end
  end

  private

  def find_or_build_billing_gateway_for_usd
    @instance.instance_billing_gateways.find{|bg| bg.currency == 'USD'} || @instance.instance_billing_gateways.build(currency: 'USD')
  end

  def find_instance
    @instance = platform_context.instance
  end

end
