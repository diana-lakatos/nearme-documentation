class Manage::UsersController < Manage::BaseController
  before_filter :find_company
  before_filter :redirect_if_no_company

  def index
    @users = @company.users.without(current_user).ordered_by_email
  end

  def new
    @user = @company.users.build(params[:user])

    render partial: 'user_form'
  end

  def create
    @user = User.where(:email => params[:user][:email]).first
    if !@user
      flash.now[:warning] = t('flash_messages.manage.users.user_does_not_exists')
      new
    elsif @user.companies.any?
      flash.now[:warning] = t('flash_messages.manage.users.user_cannot_be_invited')
      new
    else
      @company.users << @user
      flash[:success] = t('flash_messages.manage.users.user_added', name: @user.name, company_name: @company.name)
      redirect_to manage_users_url
      render_redirect_url_as_json if request.xhr?
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
    redirect_to manage_users_path
  end

  private

  def find_company
    @company = current_user.companies.first
  end

  def redirect_if_no_company
    unless @company
      flash[:warning] = t('flash_messages.dashboard.add_your_company')
      redirect_to new_space_wizard_url
    end
  end
end
