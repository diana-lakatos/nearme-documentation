class Feed < ActiveRecord::Base
  belongs_to :user
  belongs_to :listing
  belongs_to :reservation

  scope :latest, :order => "created_at desc"
end
