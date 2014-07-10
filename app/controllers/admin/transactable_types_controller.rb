class Admin::TransactableTypesController < Admin::ResourceController

  def destroy
    TransactableType.find(params[:id]).destroy
    redirect_to admin_instance_path(params[:instance_id])
  end

  def transactable_type_params
    params.require(:transactable_type).permit(secured_params.transactable_type)
  end
end
