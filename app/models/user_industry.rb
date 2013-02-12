class UserIndustry < ActiveRecord::Base
  self.table_name = 'industries_users'

  attr_accessible :user_id, :industry_id

  belongs_to :user
  belongs_to :industry

end
