# frozen_string_literal: true
class ActivityFeedEvent < ActiveRecord::Base
  EVENT_WHITELIST = %w(
    user_followed_user
    user_followed_transactable
    user_followed_topic

    user_updated_user_status
    user_updated_transactable_status
    user_updated_topic_status

    user_added_photos_to_transactable
    user_added_links_to_transactable

    user_created_transactable
    user_commented
    user_commented_on_transactable

    user_created_group
    user_added_photos_to_group
    user_added_links_to_group
    user_updated_group_status
    user_commented_on_user_activity

    topic_created
  ).freeze

  EVENT_BLACKLIST_FOR_USER = %w(
    user_commented
    user_commented_on_user_activity
  ).freeze

  attr_accessor :affected_objects

  include CreationFilter

  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :followed, -> { with_deleted }, polymorphic: true
  belongs_to :event_source, polymorphic: true

  has_many :comments, as: :commentable, dependent: :destroy
  has_many :spam_reports, as: :spamable

  validates :followed_type, inclusion: { in: ActivityFeedService::Helpers::FOLLOWED_WHITELIST }
  validates :event, inclusion: { in: EVENT_WHITELIST }

  scope :exclude_events, lambda {
    where('event NOT IN (?)', %w(user_followed_user user_followed_transactable user_followed_topic))
  }

  # We filter out user_commented events except for those where this user
  # commented something on another object (we filter out comments on his own
  # wall, that is, where followed = him)
  scope :exclude_this_user_comments, -> (object) do
    where("
      event not in (:blacklist) OR
      (event in (:blacklist) AND (followed_id != :user_id OR followed_type != 'User'))",
      blacklist: EVENT_BLACKLIST_FOR_USER, user_id: object.id
    ) if object.is_a?(User)
  end

  before_create :update_affected_objects
  def update_affected_objects
    if affected_objects.present?
      objects = affected_objects.compact.map { |object| ActivityFeedService::Helpers.object_identifier_for(object) }
      identifier = [ActivityFeedService::Helpers.object_identifier_for(followed)]
      self.affected_objects_identifiers = (identifier + objects).uniq
    end
  end

  def name
    followed.try(:name).presence || followed.id
  end

  def description
    if event_source.is_a?(Link)
      ActionController::Base.helpers.link_to(event_source.text, event_source.url)
    else
      followed.try(:description).presence || event_source.try(:description) || event_source.try(:text)
    end
  end

  def quotation_for(text)
    "&#147;#{text}&#148;".html_safe if text.present?
  end

  def event=(value)
    super(value.try(:to_s))
  end

  def has_body?
    %w(
      user_created_transactable
      user_created_topic
      user_updated_user_status
      user_updated_transactable_status
      user_updated_topic_status
      user_added_photos_to_transactable
      user_added_links_to_transactable
      topic_created
      user_commented_on_transactable
      user_commented

      user_created_group
      user_added_photos_to_group
      user_added_links_to_group
      user_updated_group_status
      user_commented_on_user_activity
    ).include?(event)
  end

  # Since both restrictions are the same
  alias is_reportable? has_body?

  def i18n_key
    "activity_feed.events.#{event}"
  end

  def creator
    event_source.try(:user) || event_source.try(:creator)
  end

  def creator_id
    creator.try(:id)
  end

  def reported_by(user, ip)
    if user
      spam_reports.where(user: user).first
    else
      spam_reports.where(ip_address: ip, user: nil).first
    end
  end

  def self.with_identifiers(sql_array)
    where('affected_objects_identifiers && ?', sql_array).order(created_at: :desc).uniq
  end

  def self.without_identifiers(sql_array)
    where.not('affected_objects_identifiers && ?', sql_array).order(created_at: :desc).uniq
  end

  def is_text_update?
    %w(
      user_updated_user_status
      user_updated_transactable_status
      user_updated_topic_status
      user_commented
      user_commented_on_transactable
    ).include?(event)
  end

  def allowed_for_user(user)
    case followed
    when Group
      user.try(:is_member_of?, followed)
    else
      true
    end
  end
end
