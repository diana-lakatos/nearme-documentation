class InstanceAdmin::BuySell::ShippingMethodsController < InstanceAdmin::BuySell::BaseController

  def index
    @shipping_methods = shipping_method_scope.all
  end

  def new
    @shipping_method = shipping_method_scope.new
    @shipping_method.calculator = Spree::Calculator::Shipping::FlatRate.new(preferred_amount: 0)
  end

  def create
    @shipping_method = shipping_method_scope.new(shipping_method_params)
    @shipping_method.display_on = 'both'
    calculator = Spree::Calculator::Shipping::FlatRate.new(calculator_params)
    calculator.preferred_currency = Spree::Config[:currency]
    @shipping_method.calculator = calculator
    if @shipping_method.save
      flash[:success] = t('flash_messages.buy_sell.shipping_method_added')
      redirect_to instance_admin_buy_sell_shipping_methods_path
    else
      flash[:error] = @shipping_method.errors.full_messages.join(', ')
      render :new
    end
  end

  def edit
    @shipping_method = shipping_method_scope.find(params[:id])
  end

  def update
    @shipping_method = shipping_method_scope.find(params[:id])
    if @shipping_method.update_attributes(shipping_method_params)
      @shipping_method.calculator.update_attributes(calculator_params)
      flash[:success] = t('flash_messages.buy_sell.shipping_method_updated')
      redirect_to instance_admin_buy_sell_shipping_methods_path
    else
      flash[:error] = @shipping_method.errors.full_messages.join(', ')
      render 'edit'
    end
  end

  def destroy
    @shipping_method = shipping_method_scope.find(params[:id])
    @shipping_method.destroy
    flash[:success] = t('flash_messages.buy_sell.shipping_method_deleted')
    redirect_to instance_admin_buy_sell_shipping_methods_path
  end

  private

  def shipping_method_scope
    Spree::ShippingMethod
  end

  def shipping_method_params
    params.require(:shipping_method).permit(secured_params.shipping_method)
  end

  def calculator_params
    params.require(:calculator_shipping_flat_rate).permit(secured_params.calculator)
  end
end
