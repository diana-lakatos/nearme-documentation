# frozen_string_literal: true
class SmsNotification < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context
  include Notification

  validates :to, :name, :content, :instance_id, presence: true
end
