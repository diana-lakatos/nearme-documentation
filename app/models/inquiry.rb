class Inquiry < ActiveRecord::Base

  belongs_to :listing
  delegate :creator_name, to: :listing, :prefix => true
  delegate :instance, to: :listing

  belongs_to :inquiring_user, class_name: "User"
  delegate :name, to: :inquiring_user, :prefix => true

  attr_accessible :message

  def to_liquid
    InquiryDrop.new(self)
  end
end
