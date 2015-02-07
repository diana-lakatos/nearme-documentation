class UserBan < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :user
  belongs_to :creator, class_name: 'User'
  belongs_to :instance

  delegate :cleanup, to: :user, prefix: true
  after_create :user_cleanup

end
