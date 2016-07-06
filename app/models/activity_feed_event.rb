class ActivityFeedEvent < ActiveRecord::Base
  # TODO:
  # topic_idz_content_pushed_to_page

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
    user_updated_group_status

    topic_created
  ).freeze

  attr_accessor :affected_objects

  include CreationFilter

  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :followed, -> { with_deleted }, polymorphic: true
  belongs_to :event_source, polymorphic: true

  has_many :comments, as: :commentable, dependent: :destroy
  has_many :spam_reports, as: :spamable

  validates_inclusion_of :followed_type, in: ActivityFeedService::Helpers::FOLLOWED_WHITELIST
  validates_inclusion_of :event, in: EVENT_WHITELIST

  scope :exclude_events, lambda {
    where("event NOT IN (?)", ['user_followed_user', 'user_followed_transactable', 'user_followed_topic'])
  }

  before_create :update_affected_objects
  def update_affected_objects
    if self.affected_objects.present?
      objects = self.affected_objects.compact.map { |object| ActivityFeedService::Helpers.object_identifier_for(object) }
      identifier = [ActivityFeedService::Helpers.object_identifier_for(followed)]
      self.affected_objects_identifiers = (identifier + objects).uniq
    end
  end

  def name
    followed.try(:name).presence || followed.id
  end

  def description
    if self.event_source.is_a?(Link)
      ActionController::Base.helpers.link_to(self.event_source.text, self.event_source.url)
    else
      followed.try(:description).presence || event_source.try(:description) || event_source.try(:text)
    end
  end

  def quotation_for(text)
    if text.present?
      "&#147;#{text}&#148;".html_safe
    end
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
      user_updated_group_status
    ).include?(event)
  end

  # Since both restrictions are the same
  alias_method :is_reportable?, :has_body?

  def i18n_key
    "activity_feed.events.#{event}"
  end

  def creator
    event_source.try(:user)
  end

  def reported_by(user, ip)
    if user
      self.spam_reports.where(user: user).first
    else
      self.spam_reports.where(ip_address: ip, user: nil).first
    end
  end

  def self.with_identifiers(sql_array)
    where("affected_objects_identifiers && ?", sql_array).order(created_at: :desc).uniq
  end

  def self.without_identifiers(sql_array)
    where.not("affected_objects_identifiers && ?", sql_array).order(created_at: :desc).uniq
  end

  def is_text_update?
    %w(
      user_updated_user_status
      user_updated_transactable_status
      user_updated_topic_status
      user_commented
      user_commented_on_transactable
    ).include?(self.event)
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
