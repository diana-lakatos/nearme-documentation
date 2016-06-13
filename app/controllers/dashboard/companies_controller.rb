class Dashboard::CompaniesController < Dashboard::BaseController

  def edit
    @company = current_user.companies.find(params[:id])
    build_approval_request_for_object(@company) unless @company.is_trusted?
  end

  def update
    @company = current_user.companies.find(params[:id])
    build_approval_request_for_object(@company) unless @company.is_trusted?
    @company.creator ||= current_user
    if @company.update_attributes(company_params)
      flash[:success] = t('flash_messages.manage.companies.company_updated')
      redirect_to edit_dashboard_company_path(@company.id)
    else
      flash.now[:error] = t('flash_messages.manage.companies.could_not_update_company')
      render :edit
    end
  end

  def company_params
    params.require(:company).permit(secured_params.company)
  end
end
