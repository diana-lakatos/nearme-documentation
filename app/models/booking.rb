class Booking < ActiveRecord::Base
  belongs_to :workplace
  belongs_to :user

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
