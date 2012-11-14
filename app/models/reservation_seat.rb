class ReservationSeat < ActiveRecord::Base

  # Reservation to which the seat is associated
  belongs_to :reservation_period
  attr_accessible :reservation_period_id

  # Name on the seat
  attr_accessible :name

  # Email address of the seat
  attr_accessible :email

  # The corresponding user, if the e-mail address matches
  belongs_to :user
  attr_accessible :user

  acts_as_paranoid

end
