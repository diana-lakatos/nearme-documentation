class Feed < ActiveRecord::Base
  belongs_to :user
  belongs_to :workplace
  belongs_to :booking
  scope :latest, :order => "created_at desc"
end
