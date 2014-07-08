class PartnerInquiry < ActiveRecord::Base
  # attr_accessible :company_name, :email, :name

  validates_presence_of :name, :company_name, :email
  validates :email, email: true
end
