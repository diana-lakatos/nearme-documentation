class SpamReport < ActiveRecord::Base

  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :user
  belongs_to :spamable, polymorphic: true

end
