class Dashboard::CompaniesController < Dashboard::BaseController

  def edit
    @company = current_user.companies.find(params[:id])
    build_approval_request_for_object(@company) unless @company.is_trusted?
  end

  def update
    @company = current_user.companies.find(params[:id])

    # https://github.com/rails/rails/issues/17368
    # assign_attributes persists the association immediately leading to half saved
    # and invalid object before save is actually hit; we try to emulate an assign_attributes
    # which works as it should by not touching the object before save, and only if valid persisting
    # all changes to DB
    filtered_params = company_params.reject { |k,v| k == 'industry_ids' }
    @company.assign_attributes(filtered_params)

    build_approval_request_for_object(@company) unless @company.is_trusted?
    @company.creator ||= current_user
    if @company.save
      # We assign the industry ids to the company if they're not blank (see above)
      # if blank, would result in invalid object post-save
      industry_ids = company_params.select { |k,v| k == 'industry_ids' }
      @company.assign_attributes(industry_ids) if industry_ids[:industry_ids].try(:select) { |item| item.present? }.present?

      flash[:success] = t('flash_messages.manage.companies.company_updated')
      redirect_to edit_dashboard_company_path(@company.id)
    else
      render :edit
    end
  end

  def company_params
    params.require(:company).permit(secured_params.company)
  end
end
