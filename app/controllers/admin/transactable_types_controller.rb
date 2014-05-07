class Admin::TransactableTypesController < Admin::ResourceController
  belongs_to :instance

  def destroy
    TransactableType.find(params[:id]).destroy
    redirect_to admin_instance_path(params[:instance_id])
  end
end
