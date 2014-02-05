class CompanyUser < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid

  attr_accessible :company_id, :user_id

  belongs_to :company
  belongs_to :user

  after_commit :user_populate_companies_metadata!
  delegate :populate_companies_metadata!, to: :user, :prefix => true

end
