class InstanceAdmin::Settings::Payments::PaymentGatewaysController < InstanceAdmin::Settings::BaseController
  def new
    @payment_gateway = payment_gateway_class.new
  end

  def create
    @payment_gateway = payment_gateway_class.new(payment_gateway_params)

    if @payment_gateway.valid?
      if @payment_gateway.supports_multiple_currency?
        @payment_gateway.payment_currency_ids = @payment_gateway.available_currencies.map(&:id)
      end
      @payment_gateway.save
      redirect_to redirect_url(@payment_gateway), notice: t('flash_messages.instance_admin.settings.payments.payment_gateways.created')
    else
      render :new
    end
  end

  def edit
    @payment_gateway = payment_gateway_class.find(params[:id])
    @payment_gateway.build_payment_methods(active: true)
  end

  def update
    @payment_gateway = payment_gateway_class.find(params[:id])
    if @payment_gateway.update_attributes(payment_gateway_params)
      redirect_to redirect_url, notice: t('flash_messages.instance_admin.settings.payments.payment_gateways.updated')
    else
      flash.now[:error] = @payment_gateway.errors.full_messages.join(', ')
      render :edit
    end
  end

  def destroy
    @payment_gateway = payment_gateway_class.find(params[:id])
    if @payment_gateway.deletable?
      @payment_gateway.destroy
      flash[:notice] = t('flash_messages.instance_admin.settings.payments.payment_gateways.deleted')
    else
      flash[:error] = t('flash_messages.instance_admin.settings.payments.payment_gateways.can_not_be_deleted')
    end
    redirect_to redirect_url
  end

  private

  def payment_gateway_class
    PaymentGateway::PAYMENT_GATEWAYS.values.find { |type| type == params[:payment_gateway][:type] if params[:payment_gateway] && params[:payment_gateway][:type] }.try(:constantize) || PaymentGateway
  end

  def payment_gateway_params
    params.require(:payment_gateway).permit(secured_params.payment_gateway(payment_gateway_class))
  end

  def redirect_url(payment_gateway = nil)
    if payment_gateway
      url_for([:instance_admin, :settings, payment_gateway]) + '/edit'
    else
      url_for([:instance_admin, :settings, :payments])
    end
  end

  def permitting_controller_class
    'Settings'
  end
end
