# frozen_string_literal
class EmailNotification < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context
  include NotificationConcern

  validates :to, :name, :content, :from, :instance_id, presence: true

end
