class Admin::TransactableTypeAttributesController < Admin::ResourceController
  belongs_to :transactable_type

  before_filter :eval_parameters, :only => [:create, :update]

  def create
    resource = TransactableTypeAttribute.new(params[:transactable_type_attribute])
    resource.transactable_type_id = params[:transactable_type_id]
    resource.instance_id = TransactableType.find(params[:transactable_type_id]).instance_id
    if resource.save
      redirect_to admin_transactable_type_transactable_type_attribute_path(resource.transactable_type , resource)
    else
      render action: :new
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
end
