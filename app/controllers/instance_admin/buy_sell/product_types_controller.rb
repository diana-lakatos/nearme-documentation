class InstanceAdmin::BuySell::ProductTypesController < InstanceAdmin::BuySell::BaseController

  def index
    @product_types = product_type_scope.all
  end

  def new
    @product_type = product_type_scope.new
  end

  def edit
    @product_type = product_type_scope.find(params[:id])
  end

  def create
    @product_type = product_type_scope.new(product_type_params)
    if @product_type.save
      CustomAttributes::CustomAttribute::Creator.new(@product_type, bookable_noun: @product_type.name).create_spree_product_type_attributes!
      Utils::FormComponentsCreator.new(@product_type).create!
      TransactableType.create(name: @product_type.name, buyable: true)
      flash[:success] = t 'flash_messages.instance_admin.buy_sell.product_types.created'
      redirect_to instance_admin_buy_sell_product_types_path
    else
      flash[:error] = @product_type.errors.full_messages.to_sentence
      render action: :new
    end
  end

  def update
    @product_type = product_type_scope.find(params[:id])
    if @product_type.update_attributes(product_type_params)
      flash[:success] = t 'flash_messages.instance_admin.buy_sell.product_types.updated'
      redirect_to instance_admin_buy_sell_product_types_path
    else
      flash[:error] = @product_type.errors.full_messages.to_sentence
      render action: :edit
    end
  end

  def destroy
    @product_type = product_type_scope.find(params[:id])
    @product_type.destroy
    flash[:success] = t 'flash_messages.instance_admin.buy_sell.product_types.deleted'
    redirect_to instance_admin_buy_sell_product_types_path
  end

  private

  def product_type_scope
    Spree::ProductType
  end

  def product_type_params
    params.require(:product_type).permit(secured_params.transactable_type).tap do |whitelisted|
      if params[:product_type][:custom_csv_fields]
        whitelisted[:custom_csv_fields] = params[:product_type][:custom_csv_fields].map { |el| el = el.split('=>'); { el[0] => el[1] } }
      end
    end
  end

end

