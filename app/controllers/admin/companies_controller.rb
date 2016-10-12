class Admin::CompaniesController < Admin::ResourceController
  def company_params
    params.require(:company).permit(secured_params.company)
  end
end
