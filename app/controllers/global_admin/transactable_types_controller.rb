class GlobalAdmin::TransactableTypesController < GlobalAdmin::ResourceController

  def create
    resource = TransactableType.new(transactable_type_params)
    if resource.save
      redirect_to global_admin_instance_transactable_type_path(resource.instance, resource)
    else
      render action: :new
    end
  end

  def update
    resource = TransactableType.find(params[:id])
    if resource.update_attributes(transactable_type_params)
      redirect_to global_admin_instance_transactable_type_path(resource.instance, resource)
    else
      render action: :edit
    end

  end

  def transactable_type_params
    params.require(:transactable_type).permit(secured_params.transactable_type)
  end
end
