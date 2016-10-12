class InstanceAdmin::Projects::TransactableTypesController < InstanceAdmin::Manage::BaseController
  def index
    @project_types = TransactableType.where(name: 'Project')
  end

  def new
    @project_type = TransactableType.new
  end

  def edit
    @project_type = TransactableType.find(params[:id])
  end

  def create
    @project_type = TransactableType.new(project_type_params)
    if @project_type.save
      Utils::FormComponentsCreator.new(@project_type, project: true).create!
      flash[:success] = t 'flash_messages.instance_admin.projects.project_types.created'
      redirect_to instance_admin_projects_transactable_types_path
    else
      flash.now[:error] = @project_type.errors.full_messages.to_sentence
      render action: :new
    end
  end

  def update
    @project_type = TransactableType.find(params[:id])
    if @project_type.update_attributes(project_type_params)
      flash[:success] = t 'flash_messages.instance_admin.projects.project_types.updated'
      redirect_to instance_admin_projects_transactable_types_path
    else
      flash.now[:error] = @project_type.errors.full_messages.to_sentence
      render action: :edit
    end
  end

  def destroy
    @project_type = TransactableType.find(params[:id])
    @project_type.destroy
    flash[:success] = t 'flash_messages.instance_admin.projects.project_types.deleted'
    redirect_to instance_admin_projects_transactable_types_path
  end

  def change_state
    @project_type = TransactableType.find(params[:id])
    @project_type.update(project_type_state_params)
    render nothing: true, status: 200
  end

  private

  def project_type_params
    params.require(:transactable_type).permit(secured_params.transactable_type).tap do |whitelisted|
      whitelisted[:custom_csv_fields] = params[:transactable_type][:custom_csv_fields].map { |el| el = el.split('=>'); { el[0] => el[1] } } if params[:transactable_type][:custom_csv_fields]
    end
  end

  def project_type_state_params
    params.require(:transactable_type).permit(:enable_reviews, :show_reviews_if_both_completed)
  end
end
