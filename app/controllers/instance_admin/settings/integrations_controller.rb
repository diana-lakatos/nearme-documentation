class InstanceAdmin::Settings::IntegrationsController < InstanceAdmin::Settings::BaseController
  before_filter :find_payment_gateways

  def find_payment_gateways
    @payment_gateways = PaymentGateway.all
    @countries = Country.with_payment_gateway_support
  end

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
    @payment_gateway = PaymentGateway.find(params[:payment_gateway])
    @country = Country.find_by_alpha2(params[:country])
    @instance_payment_gateway = instance_payment_gateway
    
    respond_to do | format |
      format.js
    end
  end

  def country_instance_payment_gateways
    @country_instance_payment_gateways = @instance.country_instance_payment_gateways
    render layout: false
  end

  def create_or_update_instance_payment_gateway
    @payment_gateway = PaymentGateway.find(params[:instance_payment_gateway][:payment_gateway_id])
    @instance_payment_gateway = instance_payment_gateway
    
    if @instance_payment_gateway.id.nil?
      @instance_payment_gateway.attributes = params[:instance_payment_gateway]
      @instance_payment_gateway.save!
    else
      @instance_payment_gateway.update_attributes(params[:instance_payment_gateway])
    end

    flash[:success] = "Successfully updated payment gateway settings."
    redirect_to instance_admin_settings_integrations_path
  end

  private

  def instance_payment_gateway(attributes=nil)
    @instance.instance_payment_gateways.where(payment_gateway_id: @payment_gateway.id).first || @payment_gateway.instance_payment_gateways.build
  end
end
