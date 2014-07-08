class Manage::CompaniesController < Manage::BaseController

  def edit
    @company = current_user.companies.find(params[:id])
  end

  def update
    @company = current_user.companies.find(params[:id])
    if @company.update_attributes(company_params)
      flash[:success] = t('flash_messages.manage.companies.company_updated')
      redirect_to edit_manage_company_path(@company.id)
    else
      render :edit
    end
  end

  def company_params
    params.require(:company).permit(secured_params.company)
  end
end
