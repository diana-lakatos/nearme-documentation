class ReservationPeriod < ActiveRecord::Base

  # Reservation to which the seat is associated
  belongs_to :reservation
  attr_accessible :reservation_id

  # Listing to which the seat is associated
  belongs_to :listing
  attr_accessible :listing_id

  # Reservation date
  # TODO: add start/end time for given date
  attr_accessible :date
  validates :date, :presence => true

  acts_as_paranoid

end
