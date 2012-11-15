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

  before_save :associate_to_user

  acts_as_paranoid

  private

  # Attempt to associate to a user in our system based on email address
  def associate_to_user
    self.user ||= User.find_by_email(email) if email.present?
  end
end
