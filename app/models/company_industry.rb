class CompanyIndustry < ActiveRecord::Base
  self.table_name = 'companies_industries'

  attr_accessible :company_id, :industry_id

  belongs_to :company
  belongs_to :industry

end
