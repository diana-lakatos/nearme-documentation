class CompanyUser < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context
  has_paper_trail
  acts_as_paranoid
  has_metadata without_db_column: true

  # attr_accessible :company_id, :user_id

  belongs_to :company
  belongs_to :user
end
