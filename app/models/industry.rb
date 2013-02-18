class Industry < ActiveRecord::Base

  attr_accessible :name, :company_ids, :user_ids

  validates_presence_of :name
  validates :name, :uniqueness => true

end
