# frozen_string_literal: true
class UserStatusUpdate < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :user
  belongs_to :updateable, polymorphic: true

  has_and_belongs_to_many :topics
  has_and_belongs_to_many :transactables

  validates :text, :updateable_type, :updateable_id, presence: true
  validates :text, length: { maximum: 5000 }

  validate :group_membership, if: :user_status_for_group_updated?

  after_commit :create_activity_feed_event, on: :create

  alias_attribute :creator_id, :user_id

  def create_activity_feed_event
    event = "user_updated_#{updateable_type.to_s.downcase}_status".to_sym
    affected_objects = [user] + topics + transactables + [updateable]
    ActivityFeedService.create_event(event, user, affected_objects, self)
  end

  def can_edit?(checked_user)
    checked_user == user
  end

  private

  def group_membership
    unless user.is_member_of?(updateable)
      errors.add(:membership, I18n.t('activerecord.errors.models.user_status_update.membership'))
    end
  end

  def user_status_for_group_updated?
    updateable.is_a?(Group)
  end
end
