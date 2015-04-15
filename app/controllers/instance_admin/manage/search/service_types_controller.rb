class InstanceAdmin::Manage::Search::ServiceTypesController < InstanceAdmin::Manage::BaseController
  before_filter :find_instance
  before_filter :find_service_type, only: [:set_search, :set_custom_attribute]

  def show
    @service_types = TransactableType.all - Spree::ProductType.all
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
    @service_type.update!(transactable_type_params)
    render json: transactable_type_params, status: :ok
  end

  def set_custom_attribute
    attribute = @service_type.custom_attributes.find(params[:custom_attribute_id])
    attribute.searchable = custom_attribute_params[:searchable]
    attribute.save(validate: false)
    render json: custom_attribute_params, status: :ok
  end

  private

  def find_service_type
    @service_type = TransactableType.find(params[:service_type_id])
  end

  def find_instance
    @instance = platform_context.instance
  end

  def transactable_type_params
    params.require(:transactable_type).permit(:searchable)
  end

  def custom_attribute_params
    params.require(:custom_attribute).permit(:searchable)
  end

  def instance_params
    params.require(:instance).permit(secured_params.instance)
  end
end
