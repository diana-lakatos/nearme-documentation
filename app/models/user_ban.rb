class UserBan < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :user
  belongs_to :creator, class_name: 'User'
  belongs_to :instance

  after_create :ban_user!
  after_destroy :unban_user!

  def ban_user!
    user.perform_cleanup!
    user.update_attribute(:banned_at, created_at)
  end

  def unban_user!
    user.recover_companies
    user.update_attribute(:banned_at, nil)
  end
end
