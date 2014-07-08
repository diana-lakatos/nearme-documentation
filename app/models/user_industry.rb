class UserIndustry < ActiveRecord::Base
  acts_as_paranoid
  # attr_accessible :user_id, :industry_id

  belongs_to :user
  belongs_to :industry

end
