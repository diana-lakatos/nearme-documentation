class InstanceAdmin::Manage::TransactableTypes::FormComponentsController < InstanceAdmin::Manage::BaseController

  before_filter :find_transactable_type

  def index
    @form_components = @transactable_type.form_components.rank(:rank).order('form_type')
  end

  def new
    @form_component = @transactable_type.form_components.build
  end

  def create
    @form_component = @transactable_type.form_components.build(form_component_params)
    if @form_component.save
      flash[:success] = t 'flash_messages.instance_admin.manage.form_component.created'
      redirect_to instance_admin_manage_transactable_type_form_components_path(@transactable_type)
    else
      flash[:error] = @form_component.errors.full_messages.to_sentence
      render action: :new
    end
  end

  def edit
    @form_component = @transactable_type.form_components.find(params[:id])
  end

  def update
    @form_component = @transactable_type.form_components.find(params[:id])
    if @form_component.update_attributes(form_component_params)
      flash[:success] = t 'flash_messages.instance_admin.manage.form_component.updated'
      redirect_to instance_admin_manage_transactable_type_form_components_path(@transactable_type)
    else
      flash[:error] = @form_component.errors.full_messages.to_sentence
      render action: :edit
    end
  end

  def destroy
    @form_component = @transactable_type.form_components.find(params[:id])
    @form_component.destroy
    flash[:success] = t 'flash_messages.instance_admin.manage.form_component.deleted'
    redirect_to edit_instance_admin_manage_transactable_type_form_components_path(@transactable_type)
  end

  def update_rank
    @form_component = @transactable_type.form_components.find(params[:id])
    @form_component.update_attribute(:rank_position, params[:rank_position])
    respond_to do |format|
      format.json { head :ok }
    end

  end

  private

  def find_transactable_type
    @transactable_type = TransactableType.find(params[:transactable_type_id])
  end

  def permitting_controller_class
    'manage'
  end

  def form_component_params
    params.require(:form_component).permit(secured_params.form_component).tap do |whitelisted|
      whitelisted[:form_fields] = params[:form_component][:form_fields].map { |el| el = el.split('=>'); { el[0] => el[1] } } if params[:form_component][:form_fields]
    end

  end
end
