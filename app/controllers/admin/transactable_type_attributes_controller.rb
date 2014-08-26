class Admin::TransactableTypeAttributesController < Admin::ResourceController

  before_filter :find_transactable_type
  before_filter :eval_parameters, :only => [:create, :update]

  def create
    resource = TransactableTypeAttribute.new(transactable_type_attribute_params)
    resource.transactable_type_id = params[:transactable_type_id]
    resource.instance_id = TransactableType.find(params[:transactable_type_id]).instance_id
    if resource.save
      redirect_to admin_transactable_type_transactable_type_attribute_path(resource.transactable_type , resource)
    else
      render action: :new
    end
  end

  def update
    resource = TransactableTypeAttribute.find(params[:id])
    if resource.update_attributes(transactable_type_attribute_params)
      redirect_to admin_transactable_type_transactable_type_attribute_path(resource.transactable_type , resource)
    else
      render action: :edit
    end

  end

  def destroy
    TransactableTypeAttribute.find(params[:id]).destroy
    redirect_to admin_instance_transactable_type_path(Instance.find(params[:transactable_type_id]), params[:transactable_type_id])
  end

  def eval_parameters
    if params[:transactable_type_attribute]
      %w(validation_rules valid_values input_html_options wrapper_html_options).each do |serialized_param|
        params[:transactable_type_attribute][serialized_param] = eval(params[:transactable_type_attribute][serialized_param]) if params[:transactable_type_attribute][serialized_param].present?
      end
    end
  end

  def transactable_type_attribute_params
    params.require(:transactable_type_attribute).permit(secured_params.transactable_type_attribute).tap do |whitelisted|
      whitelisted[:validation_rules] = params[:transactable_type_attribute][:validation_rules]
      whitelisted[:valid_values] = params[:transactable_type_attribute][:valid_values]
      whitelisted[:wrapper_html_options] = params[:transactable_type_attribute][:wrapper_html_options]
      whitelisted[:input_html_options] = params[:transactable_type_attribute][:input_html_options]
    end
  end

  private

  def find_transactable_type
    @transactable_type = TransactableType.find(params[:transactable_type_id])
  end
end
