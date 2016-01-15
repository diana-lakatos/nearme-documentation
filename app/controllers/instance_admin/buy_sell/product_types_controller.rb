class InstanceAdmin::BuySell::ProductTypesController < InstanceAdmin::BuySell::BaseController
  before_filter :find_product_type, except: [:index, :new, :create]

  def index
    @product_types = product_type_scope.all
  end

  def new
    @product_type = product_type_scope.new
  end

  def edit
  end

  def create
    @product_type = product_type_scope.new(product_type_params)
    if @product_type.save
      Utils::FormComponentsCreator.new(@product_type).create!
      @product_type.create_rating_systems
      flash[:success] = t 'flash_messages.instance_admin.buy_sell.product_types.created'
      redirect_to instance_admin_buy_sell_product_types_path
    else
      flash.now[:error] = @product_type.errors.full_messages.to_sentence
      render action: :new
    end
  end

  def update
    if @product_type.update_attributes(product_type_params)
      flash[:success] = t 'flash_messages.instance_admin.buy_sell.product_types.updated'
      redirect_to instance_admin_buy_sell_product_types_path
    else
      flash.now[:error] = @product_type.errors.full_messages.to_sentence
      render action: params[:action_name]
    end
  end

  def destroy
    @product_type.destroy
    flash[:success] = t 'flash_messages.instance_admin.buy_sell.product_types.deleted'
    redirect_to instance_admin_buy_sell_product_types_path
  end

  def search_settings
  end

  private

  def find_product_type
    @product_type = product_type_scope.find(params[:id])
  end

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

