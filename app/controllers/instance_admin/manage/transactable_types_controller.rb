class InstanceAdmin::Manage::TransactableTypesController < InstanceAdmin::Manage::BaseController

  before_filter :set_theme

  def index
    @transactable_types = TransactableType.all
  end

  def update
    @transactable_type = TransactableType.find(params[:id])
    if @transactable_type.update_attributes(transactable_type_params)
      flash[:success] = t 'flash_messages.instance_admin.manage.transactable_types.updated'
      redirect_to instance_admin_manage_transactable_types_path
    else
      flash[:error] = @transactable_type.errors.full_messages.to_sentence
      render action: :edit
    end
  end

  private

  def set_theme
    @theme_name = 'orders-theme'
  end

  def transactable_type_params
    params.require(:transactable_type).permit(secured_params.transactable_type).tap do |whitelisted|
      whitelisted[:custom_csv_fields] = params[:transactable_type][:custom_csv_fields].map { |el| el = el.split('=>'); { el[0] => el[1] } } if params[:transactable_type][:custom_csv_fields]
    end

  end

end

