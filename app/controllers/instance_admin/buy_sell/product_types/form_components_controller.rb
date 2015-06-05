class InstanceAdmin::BuySell::ProductTypes::FormComponentsController < InstanceAdmin::FormComponentsController
  before_filter :form_type, only: [:index]

  def create_as_copy
    product_type_id = params[:copy_template][:form_componentable_id]
    form_type = params[:copy_template][:form_type]
    Spree::ProductType.find(product_type_id).form_components.where(form_type: form_type).each do |form_component|
      @form_componentable.form_components << form_component.dup
    end

    redirect_to redirect_path
  end

  private

  def form_type
    @form_type = 'product_attributes'
  end

  def find_form_componentable
    @form_componentable = Spree::ProductType.find(params[:product_type_id])
  end

  def redirect_path
    instance_admin_buy_sell_product_type_form_components_path(@form_componentable)
  end

  def permitting_controller_class
    @controller_scope ||= 'buy_sell'
    'buysell'
  end
end
