class InstanceAdmin::BuySell::ProductTypes::CustomValidatorsController < InstanceAdmin::CustomValidatorsController

  protected

  def redirect_path
    instance_admin_buy_sell_product_type_custom_validators_path(@validatable)
  end

  def find_validatable
    @validatable = Spree::ProductType.find(params[:product_type_id])
  end

  def permitting_controller_class
    @controller_scope ||= 'buy_sell'
    'buysell'
  end

  def available_attributes
    @attributes = Spree::Product.column_names.map{ |column| [column.humanize, column] }
  end

  def set_breadcrumbs
    @breadcrumbs_title = BreadcrumbsList.new(
      { :url => instance_admin_buy_sell_product_types_path, :title => t('instance_admin.buy_sell.product_types.product_types') },
      { :url => instance_admin_buy_sell_product_type_custom_validators_path, :title => t('instance_admin.manage.service_types.custom_validators') }
    )
  end
end
