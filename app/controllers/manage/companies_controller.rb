class Manage::CompaniesController < Manage::BaseController

  def edit
    @theme_name = 'product-theme'

    @company = current_user.companies.find(params[:id])
    build_approval_request_for_object(@company) unless @company.is_trusted?
  end

  def update
    @company = current_user.companies.find(params[:id])
    @company.assign_attributes(company_params)
    build_approval_request_for_object(@company) unless @company.is_trusted?
    if @company.save
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
