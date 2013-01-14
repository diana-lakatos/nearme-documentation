class Reservation < ActiveRecord::Base
  belongs_to :listing
  belongs_to :owner, :class_name => "User"

  attr_accessible :cancelable, :confirmation_email, :date, :deleted_at, :listing_id,
    :owner_id, :periods, :state, :user, :comment

  has_many :periods,
           :class_name => "ReservationPeriod",
           :dependent => :destroy

  has_many :charges,
           :dependent => :destroy

  validates :periods, :length => { :minimum => 1 }

  before_validation :set_total_cost, on: :create
  before_validation :set_currency, on: :create
  after_create      :auto_confirm_reservation

  acts_as_paranoid

  monetize :total_amount_cents

  state_machine :state, :initial => :unconfirmed do
    after_transition :unconfirmed => :confirmed, :do => :charge_stripe_customer

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

  scope :not_rejected_or_cancelled, lambda {
    without_state(:cancelled, :rejected)
  }

  def user=(value)
    self.owner = value
    self.confirmation_email = value.email
  end

  def date=(value)
    periods.build :date => value, :quantity => 1
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

  def add_period(date, quantity = 1, assignees = [])
    periods.build :date => date, :quantity => quantity, :assignees => assignees
  end

  def total_amount_cents
    if persisted?
      super
    else
      calculate_total_cost
    end
  end

  # Number of desks booked accross all days
  def desk_days
    # NB: Would use +sum+ but AR doesn't use the internal collection for non-persisted records (it attempts to load the target)
    total = 0
    periods.each do |period|
      total += period.quantity
    end
    total
  end

  private

    def calculate_total_cost
      # NB: use of 'size' not 'count' here is deliberate - seats/periods may not be persisted at this point!
      unit_prices = listing.unit_prices.reject { |unit_price| unit_price.price_cents.nil? }.sort_by { |unit_price| unit_price.period }.reverse
      desk_days_to_apply = desk_days * Listing::MINUTES_IN_DAY
      total = unit_prices.reduce(0) { |memo, unit_price|
        applications = desk_days_to_apply / unit_price.period
        desk_days_to_apply -= applications * unit_price.period
        memo + applications * unit_price.price_cents
      }
    end

    def set_total_cost
      self.total_amount_cents = calculate_total_cost
    end

    def set_currency
      self.currency = self.listing.location.currency
    end

    def auto_confirm_reservation
      confirm! unless listing.confirm_reservations?
    end

    def charge_stripe_customer
      charge = self.charges.build(amount: total_amount_cents)

      if self.create_charge
        stripe_charge = Stripe::Charge.create(
          amount: total_amount_cents,
          currency: "AUD", #currency,
          customer: owner.stripe_id
        )
      end

      charge.success = true
      charge.response = stripe_charge.to_yaml
      charge.save!
    rescue => e
      charge.success = false
      charge.response = e.to_yaml
      charge.save!
    end
end
