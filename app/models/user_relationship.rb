class UserRelationship < ActiveRecord::Base

  # User being followed
  attr_accessible :followed_id
  validates :followed_id, presence: true

  # User who is interested in the above user
  attr_accessible :follower_id
  validates :follower_id, presence: true

  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  # ...
  attr_accessible :deleted_at
  acts_as_paranoid

end
