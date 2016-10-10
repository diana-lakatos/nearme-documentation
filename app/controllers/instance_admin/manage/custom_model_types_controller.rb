class InstanceAdmin::Manage::CustomModelTypesController < InstanceAdmin::Manage::TransactableTypesController
  def create
    @transactable_type = resource_class.new(transactable_type_params)
    if @transactable_type.save
      flash[:success] = t "flash_messages.instance_admin.#{controller_scope}.#{translation_key}.created"
      redirect_to [:instance_admin, controller_scope, resource_class]
    else
      flash[:error] = @transactable_type.errors.full_messages.to_sentence
      render action: :new
    end
  end

  private

  def resource_class
    CustomModelType
  end

  def transactable_type_params
    params.require(:custom_model_type).permit(secured_params.custom_model_type)
  end
end
