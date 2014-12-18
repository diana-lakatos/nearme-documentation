class Manage::BuySell::BaseController < Manage::BaseController

  before_filter :find_company
  before_filter :set_theme

  private

  def find_company
    @company = current_user.companies.first
  end

  def find_product
    @product = @company.products.with_deleted.friendly.find(params[:product_id] || params[:id])
  end

  def location_after_save
    edit_manage_buy_sell_product_url(@product)
  end

  def set_theme
    @theme_name = 'product-theme'
  end
end