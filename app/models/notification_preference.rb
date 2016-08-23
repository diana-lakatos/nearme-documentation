class NotificationPreference < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :user

  scope :recurring, -> { where(email_frequency: %w(weekly)) }
  scope :immediate, -> { where(email_frequency: %w(immediately)) }
end
