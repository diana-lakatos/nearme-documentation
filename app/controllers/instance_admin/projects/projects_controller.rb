class InstanceAdmin::Projects::ProjectsController < InstanceAdmin::Projects::BaseController
  defaults resource_class: Transactable, collection_name: 'projects', instance_name: 'project', route_prefix: 'instance_admin'

  def index
  end

  def edit
    @project = Transactable.find(params[:id])
  end

  def update
    @project = Transactable.find(params[:id])

    @project.assign_attributes(transactable_params)
    @project.save(validate: false)

    flash[:success] = "#{@project.name} has been updated successfully"
    redirect_to instance_admin_projects_projects_path
  end

  def destroy
    @project = Transactable.find(params[:id])
    @project.destroy
    flash[:success] = "#{@project.name} has been deleted"
    redirect_to instance_admin_projects_projects_path
  end

  def restore
    @project = Transactable.with_deleted.find(params[:id])
    @project.restore
    flash[:success] = "#{@project.name} has been restored"
    redirect_to instance_admin_projects_projects_path
  end

  protected

  def transactable_params
    params[:transactable].permit(:featured, category_ids: [])
  end

  def collection_search_fields
    %w(name)
  end

  def collection
    if @projects.blank?
      @project_search_form = InstanceAdmin::ProjectSearchForm.new
      @project_search_form.validate(params)
      @projects = SearchService.new(Transactable.order('created_at DESC').with_deleted).search(@project_search_form.to_search_params).paginate(page: params[:page])
    end

    @projects
  end
end
