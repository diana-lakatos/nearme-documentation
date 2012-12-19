class ReservationPeriod < ActiveRecord::Base

  # Reservation to which the seat is associated
  belongs_to :reservation
  attr_accessible :reservation_id

  # Listing to which the seat is associated
  belongs_to :listing
  attr_accessible :listing_id

  # Seats for this date
  has_many :seats,
           :class_name => 'ReservationSeat',
           :dependent => :destroy

  attr_accessible :quantity, :assignees

  # Reservation date
  # TODO: add start/end time for given date
  attr_accessible :date
  validates :date, :presence => true
  validates :seats, :length => { :minimum => 1 }

  before_save :set_listing

  acts_as_paranoid

  def quantity
    seats.size
  end

  def quantity=(quantity)
    quantity.times do
      seats.build
    end
  end

  def assignees=(assignees)
    assignees = assignees.dup
    seats.each do |seat|
      if user = assignees.shift
        case user
        when User
          seat.user = user
        else
          user.stringify_keys!
          seat.email = user['email']
          seat.name  = user['name']
        end

        seat.save!
      end
    end
  end

  private

  def set_listing
    # Check for existence of reservation, as record may be orphaned if rolling back via rails3_acts_as_paranoid
    self.listing ||= reservation.listing if reservation
  end

end
