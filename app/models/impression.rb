# frozen_string_literal: true
class Impression < ActiveRecord::Base
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context
  belongs_to :impressionable, polymorphic: true
  scope :last_x_days, ->(days_in_past) { where('DATE(impressions.created_at) >= ? ', days_in_past.days.ago) }

  # attr_accessible :impressionable_id, :impressionable_type, :ip_address

  def to_liquid
    @impression_drop ||= ImpressionDrop.new(self)
  end
end
