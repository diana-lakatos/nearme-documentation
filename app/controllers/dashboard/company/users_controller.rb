class Dashboard::Company::UsersController < Dashboard::Company::BaseController
  def collaborations_for_current_user
    @user = User.find(params[:id])
    session[:user_to_be_invited] = @user.id
  end

  def bulk_collaborations_for_current_user
    @collaborators = User.where(id: params[:collaborator_ids])
  end
end
