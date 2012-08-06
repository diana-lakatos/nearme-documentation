class Inquiry < ActiveRecord::Base

  belongs_to :listing
  belongs_to :inquiring_user, class_name: "User"

  attr_accessible :message

end
