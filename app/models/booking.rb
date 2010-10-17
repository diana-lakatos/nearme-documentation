class Booking < ActiveRecord::Base
  belongs_to :workplace
  belongs_to :user

  scope :upcoming, lambda {
    where('date >= ?', Time.now.to_date).order('date ASC')
  }
  
  scope :visible, lambda {
    without_state(:cancelled).upcoming
  }

  validates_presence_of :date
  validate :date_not_past?
  
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

    event :cancel do
      transition [:unconfirmed, :confirmed] => :cancelled
    end
  end
end
