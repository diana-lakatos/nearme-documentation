class InstanceAdmin::Manage::Search::ProductTypesController < InstanceAdmin::Manage::BaseController
  before_filter :find_instance
  before_filter :find_product_type, only: [:set_search, :set_custom_attribute]

  def show
    @product_types = Spree::ProductType.all
    @controller_scope ||= 'manage'
  end

  def update
    @instance.update_attributes(instance_params)
    if @instance.save
      flash[:success] = t('flash_messages.search.setting_saved')
      redirect_to instance_admin_manage_search_path
    else
      flash[:error] = @instance.errors.full_messages.to_sentence
      render :show
    end
  end

  def set_search
    @product_type.update!(product_type_params)
    render json: product_type_params, status: :ok
  end

  def set_custom_attribute
    attribute = @product_type.custom_attributes.find(params[:custom_attribute_id])
    attribute.searchable = custom_attribute_params[:searchable]
    attribute.save(validate: false)
    render json: custom_attribute_params, status: :ok
  end

  private

  def permitting_controller_class
    self.class.to_s.deconstantize.deconstantize.demodulize
  end

  def find_product_type
    @product_type = Spree::ProductType.find(params[:product_type_id])
  end

  def find_instance
    @instance = platform_context.instance
  end

  def product_type_params
    params.require(:product_type).permit(secured_params.product_type)
  end

  def custom_attribute_params
    params.require(:custom_attribute).permit(:searchable)
  end

  def instance_params
    params.require(:instance).permit(secured_params.instance)
  end
end
