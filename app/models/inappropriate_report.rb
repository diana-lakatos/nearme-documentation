class InappropriateReport < ActiveRecord::Base
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :user
  belongs_to :reportable, polymorphic: true

  validates_presence_of :reason

  scope :for_user, lambda { |user|
    where(user_id: user.id)
  }

  scope :for_reportable, lambda { |reportable|
    where(reportable: reportable)
  }
end
