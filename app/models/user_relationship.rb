class UserRelationship < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context

  # User being followed
  # attr_accessible :followed_id, :authentication_id
  validates :followed_id, presence: true

  # User who is interested in the above user
  # attr_accessible :follower_id

  validates :follower_id, presence: true

  belongs_to :follower, class_name: "User", touch: true
  belongs_to :followed, class_name: "User", touch: true
  belongs_to :authentication

end
