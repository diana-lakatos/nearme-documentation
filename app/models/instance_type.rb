class InstanceType < ActiveRecord::Base
  has_many :instances
  
  # attr_accessible :name
end
