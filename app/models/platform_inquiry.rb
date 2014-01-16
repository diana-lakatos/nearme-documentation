class PlatformInquiry < ActiveRecord::Base
  validates :email, :name, presence: true
  validates :email, email: true
end
