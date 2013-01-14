class Charge < ActiveRecord::Base
  attr_accessible :amount, :reservation_id, :response, :success
  belongs_to :reservation
end
