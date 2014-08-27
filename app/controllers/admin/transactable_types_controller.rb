class Admin::TransactableTypesController < Admin::ResourceController

  def create
    resource = TransactableType.new(transactable_type_params)
    if resource.save
      redirect_to admin_instance_transactable_type_path(resource.instance, resource)
    else
      render action: :new
    end
  end

  def update
    resource = TransactableType.find(params[:id])
    if resource.update_attributes(transactable_type_params)
      redirect_to admin_instance_transactable_type_path(resource.instance, resource)
    else
      render action: :edit
    end

  end

  def transactable_type_params
    params.require(:transactable_type).permit(secured_params.transactable_type).tap do |whitelisted|
      whitelisted[:pricing_options] = params[:transactable_type][:pricing_options]
      whitelisted[:pricing_validation] = params[:transactable_type][:pricing_validation]
    end

  end
end
