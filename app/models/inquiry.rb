class Inquiry < ActiveRecord::Base

  belongs_to :listing
  delegate :creator_name, to: :listing, :prefix => true

  belongs_to :inquiring_user, class_name: "User"
  delegate :name, to: :inquiring_user, :prefix => true

  attr_accessible :message

end
