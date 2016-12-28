class GlobalAdmin::CustomAttributesController < GlobalAdmin::ResourceController
  before_filter :find_transactable_type
  before_filter :eval_parameters, only: [:create, :update]

  def create
    resource = CustomAttributes::CustomAttribute.new(custom_attribute_params)
    resource.transactable_type_id = params[:transactable_type_id]
    resource.instance_id = TransactableType.find(params[:transactable_type_id]).instance_id
    if resource.save
      redirect_to global_admin_transactable_type_custom_attribute_path(resource.transactable_type , resource)
    else
      render action: :new
    end
  end

  def update
    resource = CustomAttributes::CustomAttribute.find(params[:id])
    if resource.update_attributes(custom_attribute_params)
      redirect_to global_admin_transactable_type_custom_attribute_path(resource.transactable_type , resource)
    else
      render action: :edit
    end
  end

  def destroy
    CustomAttributes::CustomAttribute.find(params[:id]).destroy
    redirect_to global_admin_instance_transactable_type_path(Instance.find(params[:transactable_type_id]), params[:transactable_type_id])
  end

  def eval_parameters
    if params[:custom_attribute]
      %w(validation_rules valid_values input_html_options wrapper_html_options).each do |serialized_param|
        params[:custom_attribute][serialized_param] = eval(params[:custom_attribute][serialized_param]) if params[:custom_attribute][serialized_param].present?
      end
    end
  end

  def custom_attribute_params
    params.require(:custom_attribute).permit(secured_params.custom_attribute).tap do |whitelisted|
      whitelisted[:validation_rules] = params[:custom_attribute][:validation_rules]
      whitelisted[:valid_values] = params[:custom_attribute][:valid_values]
      whitelisted[:wrapper_html_options] = params[:custom_attribute][:wrapper_html_options]
      whitelisted[:input_html_options] = params[:custom_attribute][:input_html_options]
    end
  end

  private

  def find_transactable_type
    @transactable_type = TransactableType.find(params[:transactable_type_id])
  end
end
