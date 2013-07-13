class Partner < ActiveRecord::Base
  attr_accessible :name, :service_fee_percent
  has_many :instances
end
