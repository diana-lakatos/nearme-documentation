class InstanceAdmin::Manage::Inventories::UserBansController < InstanceAdmin::Manage::BaseController

  def create
    @user_ban = UserBan.new
    @user_ban.user_id = params[:inventory_id]
    @user_ban.creator_id = current_user.id
    if @user_ban.save
      flash[:success] = t('flash_messages.instance_admin.inventories.user_bans.created')
    else
      flash[:error] = t('flash_messages.instance_admin.inventories.user_bans.not_created')
    end
    redirect_to instance_admin_manage_inventories_path
  end

  private

  def permitting_controller_class
    'manage'
  end

end
