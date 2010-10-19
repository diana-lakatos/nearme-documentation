class Booking < ActiveRecord::Base
  belongs_to :workplace
  belongs_to :user

  scope :on, lambda { |date|
    where(:date => date).where(:state => [:confirmed, :unconfirmed])
  }

  scope :upcoming, lambda {
    where('date >= ?', Date.today).order('date ASC')
  }

  scope :visible, lambda {
    without_state(:cancelled).upcoming
  }

  validates_presence_of :date
  validates_uniqueness_of :date, :on => :create, :scope => [:user_id, :workplace_id], :message => "you have already booked a desk for that date."
  validate :date_not_past?

  after_create :auto_confirm_booking

  def date_not_past?
    if self.date.past?
      errors.add(:date, "Who do you think you are, Marty McFly? You can't book a desk in the past!")
    end
  end

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

  protected
    def auto_confirm_booking
      confirm! unless workplace.confirm_bookings?
    end
end
