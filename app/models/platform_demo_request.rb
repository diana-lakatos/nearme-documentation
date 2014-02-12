class PlatformDemoRequest < ActiveRecord::Base
  validates :email, presence: true, email: true
  validates_presence_of :name
end
