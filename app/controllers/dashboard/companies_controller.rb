class Dashboard::CompaniesController < Dashboard::BaseController

  def edit
    @company = current_user.companies.find(params[:id])
    build_approval_request_for_object(@company) unless @company.is_trusted?
  end

  def update
    @company = current_user.companies.find(params[:id])
    build_approval_request_for_object(@company) unless @company.is_trusted?
    @company.creator ||= current_user

    # https://github.com/rails/rails/issues/17368
    # We need transaction to rollback @company. When no industries passed
    # assign_attributes saves @company that is not valid.
    Company.transaction do
      begin
        @company.update_attributes!(company_params)
        flash[:success] = t('flash_messages.manage.companies.company_updated')
        redirect_to edit_dashboard_company_path(@company.id) and return
      rescue
        raise ActiveRecord::Rollback
      end
    end
    render :edit unless @company.valid?
  end

  def company_params
    params.require(:company).permit(secured_params.company)
  end
end
