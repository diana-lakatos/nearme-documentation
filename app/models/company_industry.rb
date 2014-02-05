class CompanyIndustry < ActiveRecord::Base
  acts_as_paranoid
  attr_accessible :company_id, :industry_id

  belongs_to :company
  belongs_to :industry

  delegate :populate_industries_metadata!, :to => :company, :prefix => true
  after_commit :company_populate_industries_metadata!

end
