# frozen_string_literal: true
class Group < ActiveRecord::Base
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  include QuerySearchable
  SORT_OPTIONS_MAP = { all: 'All', featured: 'Featured', most_recent: 'Most Recent', near_me: 'Near Me', members: 'Members' }.freeze
  SORT_OPTIONS = SORT_OPTIONS_MAP.values.freeze

  belongs_to :transactable_type, -> { with_deleted }, foreign_key: 'transactable_type_id', class_name: 'GroupType'
  belongs_to :group_type, -> { with_deleted }, foreign_key: 'transactable_type_id'
  belongs_to :creator, -> { with_deleted }, class_name: 'User', inverse_of: :groups

  has_one :current_address, class_name: 'Address', as: :entity, dependent: :destroy

  has_one :cover_photo, -> { where(photo_role: 'cover') }, as: :owner, class_name: 'Photo', dependent: :destroy
  has_many :gallery_photos, -> { where(photo_role: nil) }, as: :owner, class_name: 'Photo'
  has_many :photos, as: :owner, dependent: :destroy
  has_many :links, as: :linkable, dependent: :destroy

  has_many :group_transactables, dependent: :destroy
  has_many :transactables, through: :group_transactables
  alias all_transactables transactables

  has_many :group_members, dependent: :destroy
  has_many :memberships, class_name: 'GroupMember', dependent: :destroy
  has_many :members, through: :group_members, source: :user
  has_many :approved_members, -> { GroupMember.approved }, through: :group_members, source: :user

  has_many :activity_feed_events, as: :event_source, dependent: :destroy

  has_custom_attributes target_type: 'GroupType', target_id: :transactable_type_id

  with_options reject_if: :all_blank, allow_destroy: true do |options|
    options.accepts_nested_attributes_for :current_address
    options.accepts_nested_attributes_for :cover_photo
    options.accepts_nested_attributes_for :photos
    options.accepts_nested_attributes_for :links
  end

  scope :confidential, -> { joins(:group_type).where(transactable_types: { name: %(Private Secret) }) }
  scope :not_public, -> { joins(:group_type).where(transactable_types: { name: %w(Secret Private Moderated) }) }
  scope :not_secret, -> { joins(:group_type).where.not(transactable_types: { name: 'Secret' }) }

  scope :with_date, ->(date) { where(created_at: date) }
  scope :by_search_query, lambda { |query|
    where('name ilike ? or description ilike ? or summary ilike ?', query, query, query)
  }
  scope :active, -> { where('groups.draft_at IS NULL') }

  with_options unless: ->(record) { record.draft? } do |options|
    options.validates :transactable_type, presence: true
    options.validates :name, presence: true, length: { maximum: 140 }
    options.validates :summary, presence: true, length: { maximum: 140 }
    options.validates :description, presence: true, length: { maximum: 5000 }
    options.validates :cover_photo, presence: true
  end

  validates_with CustomValidators

  before_restore :restore_group_members

  before_destroy :mark_as_destroyed_by_parent, prepend: true
  after_save :trigger_workflow_alert_for_added_group_members, unless: ->(record) { record.draft? }
  after_commit :user_created_group_event, on: :create, unless: ->(record) { record.draft? }

  delegate :public?, :moderated?, :private?, :secret?, :confidential?, to: :group_type
  delegate :custom_validators, to: :transactable_type

  def self.custom_order(sort_name, params)
    case sort_name
    when /featured/i
      where(featured: true)
    when /most recent/i
      order(created_at: :desc)
    when /near me/i
      joins(:current_address).order("#{Address.order_by_distance_sql(params[:lat], params[:lng])} ASC")
    when /members/i
      order(members_count: :desc)
    else
      all
    end
  end

  def cover_image
    cover_photo.try(:image) || Photo.new.image
  end

  def cover_photo_attributes=(attrs)
    photo = Photo.find_by(id: attrs[:id])

    if photo.present?
      photo.attributes = attrs
      self.cover_photo = photo
    end
  end

  def to_liquid
    @group_drop ||= GroupDrop.new(self)
  end

  def draft?
    draft_at.present?
  end

  def enabled?
    draft_at.nil?
  end

  def build_new_group_member
    OpenStruct.new(email: nil)
  end

  def new_group_members
    (@new_group_members || []).empty? ? [OpenStruct.new(email: nil)] : @new_group_members
  end

  def new_group_members_attributes=(attributes = {})
    @new_group_members = attributes.values.uniq { |member| member[:email] }.map do |member|
      OpenStruct.new(email: member[:email]) unless member[:email].blank?
    end.compact
  end

  def user_created_group_event
    event = :user_created_group
    user = creator.try(:object).presence || creator
    affected_objects = [user]
    ActivityFeedService.create_event(event, self, affected_objects, self)
  end

  def trigger_workflow_alert_for_added_group_members
    return true if @new_group_members.nil?

    @new_group_members.each do |group_member|
      group_member_email = group_member.email.try(:downcase)
      user = User.find_by(email: group_member_email)
      next unless user.present?

      next unless !group_members.for_user(user).exists? && user != creator
      gm = group_members.build(
        user: user,
        email: group_member_email,
        approved_by_owner_at: Time.zone.now
      )
      gm.save!

      WorkflowStepJob.perform(WorkflowStep::GroupWorkflow::MemberAddedByGroupOwner, gm.id)
    end
  end

  def restore_group_members
    group_members.only_deleted.deleted_with_group(self).each do |member|
      member.restore(recursive: true)
    end
  end

  def mark_as_destroyed_by_parent
    group_members.each { |m| m.destroyed_by_parent = true }
  end

  def members_email_recipients
    approved_members.select { |u| u.notification_preference.blank? || u.notification_preference.email_frequency.eql?('immediately') && u.notification_preference.group_updates_enabled? }
  end

  class NotFound < ActiveRecord::RecordNotFound; end
end
