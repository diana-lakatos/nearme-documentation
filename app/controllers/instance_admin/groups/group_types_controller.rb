class InstanceAdmin::Groups::GroupTypesController < InstanceAdmin::Manage::BaseController

  def index
    @group_types = GroupType.all
  end

  def update
    @group_type = GroupType.find(params[:id])
    if @group_type.update_attributes(group_type_params)
      flash[:success] = t 'flash_messages.instance_admin.groups.group_types.updated'
      redirect_to instance_admin_groups_group_types_path
    else
      flash.now[:error] = @group_type.errors.full_messages.to_sentence
      render action: :edit
    end
  end

  private

  def group_type_params
    params.require(:group_type).permit(secured_params.transactable_type)
  end

end
