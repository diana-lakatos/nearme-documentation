class CompanyIndustry < ActiveRecord::Base
  acts_as_paranoid

  has_metadata :without_db_column => true

  # attr_accessible :company_id, :industry_id

  belongs_to :company
  belongs_to :industry

end
