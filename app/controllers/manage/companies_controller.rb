class Manage::CompaniesController < Manage::BaseController

  def edit
    @company = current_user.companies.find(params[:id])
    @company.build_domain unless @company.domain
  end

  def update
    @company = current_user.companies.find(params[:id])
    if @company.update_attributes(params[:company])
      flash[:success] = t('manage.compaines.company_updated')
      redirect_to edit_manage_company_path(@company.id)
    else
      render :edit
    end
  end

end
