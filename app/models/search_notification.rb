class SearchNotification < ActiveRecord::Base
  attr_accessible :email, :latitude, :longitude, :query

  belongs_to :user

  validates :email, email: true, unless: :user
  validates_presence_of :latitude, :longitude, :query

  def email
    if user
      user.email
    else
      super
    end
  end
end
