class Reservation < ActiveRecord::Base
  belongs_to :listing
  belongs_to :owner, :class_name => "User"

  attr_accessible :cancelable, :confirmation_email, :date, :deleted_at, :listing_id,
    :owner_id, :periods, :seats, :state, :user, :comment

  has_many :periods, :class_name => "ReservationPeriod", :dependent => :destroy
  has_many :seats, :class_name => "ReservationSeat", :dependent => :destroy

  validates :periods, :length => { :minimum => 1 }
  validates :seats, :length => { :minimum => 1 }

  before_validation :set_total_cost, on: :create
  after_create      :auto_confirm_reservation

  acts_as_paranoid

  monetize :total_amount_cents

  state_machine :state, :initial => :unconfirmed do
    event :confirm do
      transition :unconfirmed => :confirmed
    end

    event :reject do
      transition :unconfirmed => :rejected
    end

    event :owner_cancel do
      transition :confirmed => :cancelled
    end

    event :user_cancel do
      transition [:unconfirmed, :confirmed] => :cancelled
    end
  end

  scope :on, lambda { |date|
    joins(:periods).
      where("reservation_periods.date" => date).
      where(:state => [:confirmed, :unconfirmed])
  }

  scope :upcoming, lambda {
    joins(:periods).
    where('date >= ?', Date.today).
    order('date')
  }

  scope :visible, lambda {
    without_state(:cancelled).upcoming
  }

  def user=(value)
    self.owner = value
    self.confirmation_email = value.email
    seats.build :user => value
  end

  def date=(value)
    periods.build :date => value
  end

  def date
    periods.first.date
  end

  # A reservation can be canceled if all of the dates are in the future
  def cancelable
    timestamp_now = Time.now.utc

    # Assume we can cancel until proven otherwise
    can_cancel = true
    periods.each { |p|
      can_cancel = false if p.date.to_time(:utc) < timestamp_now
    }

    can_cancel
  end

  private

    def set_total_cost
      # NB: use of 'size' not 'count' here is deliberate - seats/periods may not be persisted at this point!
      self.total_amount_cents ||= listing.price_cents * seats.size * periods.size
    end

    def auto_confirm_reservation
      confirm! unless listing.confirm_reservations?
    end
end
