class InstanceAdmin::BuySell::TaxRatesController < InstanceAdmin::BuySell::BaseController

  before_filter :load_data

  def index
    @tax_rates = tax_rate_scope.all
  end

  def new
    @tax_rate = tax_rate_scope.new
  end

  def create
    @tax_rate = tax_rate_scope.new(tax_rate_params)
    @tax_rate.calculator_type = @calculators.first.name
    if @tax_rate.save
      flash[:success] = t('flash_messages.buy_sell.tax_rate_added')
      redirect_to instance_admin_buy_sell_tax_rates_path
    else
      flash.now[:error] = @tax_rate.errors.full_messages.join(', ')
      render :new
    end
  end

  def edit
    @tax_rate = tax_rate_scope.find(params[:id])
  end

  def update
    @tax_rate = tax_rate_scope.find(params[:id])
    if @tax_rate.update_attributes(tax_rate_params)
      flash[:success] = t('flash_messages.buy_sell.tax_rate_updated')
      redirect_to instance_admin_buy_sell_tax_rates_path
    else
      render 'edit'
    end
  end

  def destroy
    @tax_rate = tax_rate_scope.find(params[:id])
    @tax_rate.destroy
    flash[:success] = t('flash_messages.buy_sell.tax_rate_deleted')
    redirect_to instance_admin_buy_sell_tax_rates_path
  end

  private

  def tax_rate_scope
    Spree::TaxRate
  end

  def tax_rate_params
    params.require(:tax_rate).permit(secured_params.tax_rate)
  end

  def load_data
    @available_zones = Spree::Zone.order(:name)
    @available_categories = Spree::TaxCategory.order(:name)
    @calculators = Spree::TaxRate.calculators.sort_by(&:name)
  end
end
