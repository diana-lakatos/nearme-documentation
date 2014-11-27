class Manage::BuySell::ShippingMethodsController < Manage::BuySell::BaseController
  before_filter :find_shipping_method, only: [:edit, :update, :destroy]

  def index
    @shipping_methods = @company.shipping_methods.paginate(page: params[:page], per_page: 20)
  end

  def new
    @shipping_method = @company.shipping_methods.build
    @shipping_method.calculator = Spree::Calculator::Shipping::FlatRate.new(preferred_amount: 0)
  end

  def create
    @shipping_method = @company.shipping_methods.new(shipping_method_params)
    calculator = Spree::Calculator::Shipping::FlatRate.new(calculator_params)
    calculator.preferred_currency = Spree::Config[:currency]
    @shipping_method.calculator = calculator
    if @shipping_method.save
      redirect_to location_after_save, notice: t('flash_messages.manage.shipping_method.created')
    else
      flash[:error] = t('flash_messages.manage.shipping_method.error_create')
      render :new
    end
  end

  def edit
  end

  def update
    if @shipping_method.update_attributes(shipping_method_params)
      @shipping_method.calculator.update_attributes(calculator_params)
      redirect_to location_after_save, notice: t('flash_messages.manage.shipping_method.updated')
    else
      flash[:error] = t('flash_messages.manage.shipping_method.error_update')
      render :edit
    end
  end

  def destroy
    @shipping_method.destroy
    flash[:notice] = t('flash_messages.manage.shipping_method.deleted')
    redirect_to location_after_save
   end

  private

  def location_after_save
    manage_buy_sell_shipping_methods_path
  end

  def find_shipping_method
    @shipping_method = @company.shipping_methods.find(params[:id])
  end

  def shipping_method_params
    params.require(:shipping_method).permit(secured_params.spree_shipping_method)
  end

  def calculator_params
    params.require(:calculator_shipping_flat_rate).permit(secured_params.calculator)
  end
end
