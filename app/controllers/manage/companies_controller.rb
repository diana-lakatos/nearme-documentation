class Manage::CompaniesController < Manage::BaseController

  def edit
    @company = current_user.companies.find(params[:id])
  end

  def update
    @company = current_user.companies.find(params[:id])
    if @company.update_attributes(params[:company])
      flash[:success] = t('flash_messages.manage.compaines.company_updated')
      redirect_to edit_manage_company_path(@company.id)
    else
      render :edit
    end
  end

end
