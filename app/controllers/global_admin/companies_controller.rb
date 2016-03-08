class GlobalAdmin::CompaniesController < GlobalAdmin::ResourceController
  def company_params
    params.require(:company).permit(secured_params.company)
  end
end
