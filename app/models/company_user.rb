class CompanyUser < ActiveRecord::Base

  acts_as_paranoid
  has_paper_trail

  attr_accessible :company_id, :user_id, :deleted_at

  belongs_to :company
  belongs_to :user

end
