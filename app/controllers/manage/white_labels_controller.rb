class Manage::WhiteLabelsController < Manage::BaseController

  def edit
    @company = current_user.companies.find(params[:id])
  end

  def update
    @company = current_user.companies.find(params[:id])
    if @company.update_attributes(params[:company])
      flash[:success] = t('flash_messages.manage.compaines.white_label_updated')
      redirect_to edit_manage_white_label_path(@company.id)
    else
      render :edit
    end
  end

end
