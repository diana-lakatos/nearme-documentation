# frozen_string_literal: true
class Photo < ActiveRecord::Base
  include RankedModel
  VALID_OWNER_TYPES = %w(Transactable Group).freeze
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  # skip_activity_feed_event is used to prevent creating a new event
  # on recreate_versions
  attr_accessor :force_regenerate_versions, :skip_activity_feed_event

  has_metadata without_db_column: true

  ranks :position, with_same: [:owner_id, :owner_type, :creator_id]

  inherits_columns_from_association([:creator_id], :owner)
  # validates :owner_type, inclusion: { in: VALID_OWNER_TYPES }, presence: true

  belongs_to :owner, -> { with_deleted }, polymorphic: true, touch: true
  belongs_to :creator, -> { with_deleted }, class_name: 'User'
  belongs_to :instance

  default_scope -> { rank(:position) }
  scope :not_confidential, ->{ where(owner_type: Transactable.to_s).where.not(owner_id: Transactable.confidential.pluck(:id)) }

  validates :image, presence: true,  if: ->(p) { !p.image_original_url.present? }

  validates :caption, length: { maximum: 120, allow_blank: true }

  mount_uploader :image, PhotoUploader

  # Don't delete the photo from s3
  skip_callback :commit, :after, :remove_image!

  def listing
    owner_type == 'Transactable' ? owner : nil
  end

  def listing=(object)
    self.owner = object
  end

  after_commit :user_added_photos_to_project_event, on: [:create, :update]
  after_commit :user_added_photos_to_group_event, on: [:create, :update]
  def user_added_photos_to_project_event
    return if paranoia_destroyed?
    return unless PlatformContext.current.instance.is_community?

    if owner_type == 'Transactable' && owner.present? && !owner.draft? && !skip_activity_feed_event
      event = :user_added_photos_to_transactable
      ActivityFeedService.create_event(event, owner, [owner.creator], self) unless ActivityFeedEvent.where(followed: owner, event_source: self, event: event, created_at: Time.now - 1.minute..Time.now).count > 0
    end
  end

  def user_added_photos_to_group_event
    return if paranoia_destroyed?

    if owner_type == 'Group' && owner.present?
      event = :user_added_photos_to_group
      ActivityFeedService.create_event(event, owner, [owner.creator], self) unless ActivityFeedEvent.where(followed: owner, event_source: self, event: event, created_at: Time.now - 1.minute..Time.now).count > 0
    end
  end

  def image_original_url=(value)
    super
    self.remote_image_url = value
  end

  def original_image_url
    image.url
  end

  def self.xml_attributes
    csv_fields.keys
  end

  def self.csv_fields
    { image_original_url: 'Photo URL' }
  end

  def jsonapi_serializer_class_name
    'PhotoJsonSerializer'
  end
end
