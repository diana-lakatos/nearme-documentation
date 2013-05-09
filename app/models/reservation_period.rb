class ReservationPeriod < ActiveRecord::Base
  belongs_to :reservation

  validates :date, :presence => true

  attr_accessible :date

  acts_as_paranoid

  delegate :listing, :to => :reservation

  def bookable?
    listing.available_on?(date, reservation.quantity)
  end

  def as_formatted_string
    date.strftime '%B %-d %Y'
  end
end
