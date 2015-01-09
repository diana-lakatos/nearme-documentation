class Dashboard::UsersController < Dashboard::BaseController

  def index
    @users = @company.users.without(current_user).ordered_by_email
  end

  def new
    @user = @company.users.build
  end

  def create
    @user = User.where(:email => params[:user][:email]).first
    if !@user
      flash.now[:error] = t('flash_messages.manage.users.user_does_not_exists')
    elsif @user.companies.any?
      flash.now[:error] = t('flash_messages.manage.users.user_cannot_be_invited')
    else
      @company.users << @user
      flash[:success] = t('flash_messages.manage.users.user_added', name: @user.name, company_name: @company.name)
    end
  end

  def destroy
    if current_user.id == params[:id].to_i
      flash[:warning] = t('flash_messages.manage.users.user_cant_delete_self')
    elsif @user = @company.users.without(current_user).where(id: params[:id]).first
      @company.users -= [@user]
      flash[:deleted] = t('flash_messages.manage.users.user_deleted', name: @user.try(:name), company_name: @company.name)
    else
      flash[:warning] = t('flash_messages.manage.users.user_is_not_in_company')
    end
    redirect_to dashboard_users_path
  end

  private

  def user_params
    params.require(:user).permit(secured_params.user)
  end
end
