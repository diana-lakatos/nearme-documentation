class CompanyIndustry < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context
  acts_as_paranoid

  has_metadata :without_db_column => true

  # attr_accessible :company_id, :industry_id

  belongs_to :company
  belongs_to :industry

end
