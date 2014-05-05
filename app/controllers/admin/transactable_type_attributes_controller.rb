class Admin::TransactableTypeAttributesController < Admin::ResourceController
  belongs_to :transactable_type

  before_filter :eval_parameters, :only => [:create, :update]

  def eval_parameters
    if params[:transactable_type_attribute]
      %w(validation_rules valid_values input_html_options wrapper_html_options).each do |serialized_param|
        params[:transactable_type_attribute][serialized_param] = eval(params[:transactable_type_attribute][serialized_param]) if params[:transactable_type_attribute][serialized_param].present?
      end
    end
  end
end
