class CompanyUser < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid

  attr_accessible :company_id, :user_id

  belongs_to :company
  belongs_to :user

end
