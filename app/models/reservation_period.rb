class ReservationPeriod < ActiveRecord::Base
  belongs_to :reservation

  validates :date, :presence => true

  attr_accessible :date

  acts_as_paranoid
end
