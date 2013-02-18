class UserIndustry < ActiveRecord::Base

  attr_accessible :user_id, :industry_id

  belongs_to :user
  belongs_to :industry

end
