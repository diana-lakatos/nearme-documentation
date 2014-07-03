class Manage::WhiteLabelsController < Manage::BaseController

  def edit
    @company = current_user.companies.find(params[:id])
  end

  def update
    @company = current_user.companies.find(params[:id])
    if @company.update_attributes(company_params)
      flash[:success] = t('flash_messages.manage.companies.white_label_updated')
      redirect_to edit_manage_white_label_path(@company.id)
    else
      render :edit
    end
  end

  private

  def company_params
    params.require(:company).permit(secured_params.company)
  end

end
