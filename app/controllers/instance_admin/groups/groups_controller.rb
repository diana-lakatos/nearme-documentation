class InstanceAdmin::Groups::GroupsController < InstanceAdmin::Manage::BaseController
  before_action :prepare_search_form, only: [:index]

  def index
    @groups = @search_service.search(@group_search_form.to_search_params).paginate(page: params[:page])
  end

  def edit
    @group = Group.find(params[:id])
  end

  def update
    @group = Group.find(params[:id])

    @group.assign_attributes(group_params)
    @group.save(validate: false)

    flash[:success] = "#{@group.name} has been updated successfully"
    redirect_to instance_admin_groups_groups_path
  end

  def destroy
    @group = Group.find(params[:id])
    @group.destroy
    flash[:success] = "#{@group.name} has been deleted"
    redirect_to instance_admin_groups_groups_path
  end

  def restore
    @group = Group.with_deleted.find(params[:id])
    @group.restore
    flash[:success] = "#{@group.name} has been restored"
    redirect_to instance_admin_groups_groups_path
  end

  private

  def group_params
    params.require(:group).permit(:featured, category_ids: [])
  end

  def prepare_search_form
    @group_search_form = InstanceAdmin::GroupSearchForm.new
    @group_search_form.validate(params)
    @search_service = SearchService.new(Group.order('created_at DESC').with_deleted)
  end
end
