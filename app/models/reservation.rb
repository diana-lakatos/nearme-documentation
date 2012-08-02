class Reservation < ActiveRecord::Base

  # The listing to which the reservation relates
  belongs_to :listing
  attr_accessible :listing_id

  # Reservation state: {confirmed, pending, canceled}
  attr_accessible :state

  # Confirmation email address
  # (This could be different to the owner's email address)
  attr_accessible :confirmation_email

  # Total cost of the reservation
  attr_accessible :total_amount_cents
  monetize :total_amount_cents

  # User that created the reservation
  belongs_to :owner, :class_name => "User"
  attr_accessible :owner_id

  # Reservation dates
  has_many :periods, :class_name => "ReservationPeriod", :dependent => :destroy
  validates :periods, :length => { :minimum => 1 }
  attr_accessible :periods

  # Reservation seats
  has_many :seats, :class_name => "ReservationSeat", :dependent => :destroy
  validates :seats, :length => { :minimum => 1 }
  attr_accessible :seats

  # Can this reservation be canceled?
  # This is a virtual attribute (see below)
  attr_accessible :cancelable

  # ...
  attr_accessible :deleted_at
  acts_as_paranoid

  # A reservation can be canceled if all of the dates are in the future
  def cancelable
    timestamp_now = Time.now.utc

    # Assume we can cancel until proven otherwise
    can_cancel = true
    periods.each { |p|
      can_cancel = false if p.date.to_time.utc < timestamp_now
    }

    can_cancel
  end

end
