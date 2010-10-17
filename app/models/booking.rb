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
