class InstanceAdmin::Settings::IntegrationsController < InstanceAdmin::Settings::BaseController
  before_filter :find_payment_gateways

  def countries
    if params[:country].present?
      @payment_gateways = PaymentGateway.supported_at(params[:country])
      @country = Country.find_by_alpha2(params[:country])
    end


    respond_to do | format |
      format.js
    end
  end

  def payment_gateways
    @country = Country.find_by_alpha2(params[:country])
    @payment_gateway = PaymentGateway.find_or_initialize_by_gateway_name(params[:payment_gateway])
    respond_to do | format |
      format.js
    end
  end

  def country_payment_gateways
    @country_payment_gateways = @instance.country_payment_gateways
    render layout: false
  end

  def create_or_update_payment_gateway
    @payment_gateway = PaymentGateway.find_or_initialize_by_type(params[:payment_gateway][:type])
    @payment_gateway.assign_attributes(payment_gateway_params(@payment_gateway))
    @payment_gateway.save!
    flash[:success] = "Successfully updated payment gateway settings."
    redirect_to instance_admin_settings_integrations_path
  end

  private

  def payment_gateway_params(payment_gateway)
    params.require(:payment_gateway).permit(secured_params.payment_gateway).tap do |whitelisted|
      # we need to invoke slice like .slice(:a, :b) instead of .slice([:a, b]), hence the *
      whitelisted[:live_settings] = params[:payment_gateway][:live_settings].slice(*payment_gateway.class.settings.stringify_keys.keys)
      whitelisted[:test_settings] = params[:payment_gateway][:test_settings].slice(*payment_gateway.class.settings.stringify_keys.keys)
    end
  end

  def payment_gateway(attributes=nil)
    @instance.payment_gateways.where(payment_gateway_id: @payment_gateway.id).first || @payment_gateway.payment_gateways.build
  end

  def find_payment_gateways
    @payment_gateways = PaymentGateway::PAYMENT_GATEWAYS.keys
    @countries = Country.with_payment_gateway_support
  end

end
