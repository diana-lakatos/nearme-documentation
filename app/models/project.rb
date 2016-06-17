class Project < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  # This must go before has_custom_attributes because of how the errors for the custom
  # attributes are added to the instance
  include CommunityValidators
  has_custom_attributes target_type: 'ProjectType', target_id: :transactable_type_id

  include CreationFilter
  include QuerySearchable

  attr_reader :collaborator_email
  attr_readonly :followers_count

  DEFAULT_ATTRIBUTES = %w(name description)
  SORT_OPTIONS = ['All', 'Featured', 'Most Recent', 'Most Popular', 'Collaborators']

  belongs_to :creator, -> { with_deleted }, class_name: "User", inverse_of: :projects
  counter_culture :creator,
    column_name: -> (p) { p.enabled? ? 'projects_count' : nil },
    column_names: { ["projects.draft_at IS NULL AND projects.deleted_at IS NULL"] => 'projects_count' }

  belongs_to :transactable_type, -> { with_deleted }, foreign_key: 'transactable_type_id'

  has_many :activity_feed_events, as: :followed, dependent: :destroy
  has_many :activity_feed_subscriptions, as: :followed, dependent: :destroy
  has_many :approved_project_collaborators, -> { approved }, class_name: 'ProjectCollaborator', dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :collaborating_users, through: :approved_project_collaborators, source: :user
  has_many :data_source_contents, through: :project_topics
  has_many :feed_followers, through: :activity_feed_subscriptions, source: :follower
  has_many :links, dependent: :destroy, as: :linkable
  has_many :photos, as: :owner, dependent: :destroy do
    def thumb
      (first || build).thumb
    end

    def except_cover
      offset(1)
    end
  end
  has_many :project_collaborators, dependent: :destroy
  has_many :project_topics, dependent: :destroy
  has_many :topics, through: :project_topics
  has_many :user_messages, as: :thread_context, inverse_of: :thread_context
  has_many :wish_list_items, as: :wishlistable

  scope :by_topic, -> (topic_ids) { includes(:project_topics).where(project_topics: {topic_id: topic_ids}) if topic_ids.present?}
  scope :seek_collaborators, -> { where(seek_collaborators: true) }
  scope :featured, -> { enabled.where(featured: true) }
  scope :by_search_query, lambda { |query|
    where("name ilike ? or description ilike ? or summary ilike ?", query, query, query)
  }
  scope :with_date, ->(date) { where(created_at: date) }
  scope :enabled, -> { where(draft_at: nil) }

  scope :feed_not_followed_by_user, -> (current_user) {
    where.not(id: current_user.feed_followed_projects.pluck(:id))
  }

  accepts_nested_attributes_for :photos, allow_destroy: true
  accepts_nested_attributes_for :links, reject_if: :all_blank, allow_destroy: true

  attr_accessor :photo_not_required

  validates :photos, length: {minimum: 1}, unless: ->(record) { record.draft? || record.photo_not_required || !record.transactable_type.enable_photo_required }
  validates :topics, length: {:minimum => 1}, unless: ->(record) { record.draft? }
  validates :name, :description, :summary, presence: true, unless: ->(record) { record.draft? }
  validates :name, :summary, length: { maximum: 140 }, unless: ->(record) { record.draft? }
  validates :description, length: { maximum: 5000 }, unless: ->(record) { record.draft? }

  validates_with CustomValidators

  # TODO: move to form object
  after_save :trigger_workflow_alert_for_added_collaborators, unless: ->(record) { record.draft? }

  after_destroy :fix_counter_caches
  after_destroy :fix_counter_caches_after_commit

  before_restore :restore_photos
  before_restore :restore_links
  before_restore :restore_project_collaborators

  delegate :custom_validators, to: :transactable_type

  def self.custom_order(order)
    case order
    when /most recent/i
      order('projects.created_at DESC')
    when /most popular/i
      #TODO check most popular sort after followers are implemented
      order('projects.followers_count DESC')
    when /collaborators/i
      group('projects.id').
        joins("LEFT OUTER JOIN project_collaborators pc ON projects.id = pc.project_id AND (pc.approved_by_owner_at IS NOT NULL AND pc.approved_by_user_at IS NOT NULL AND pc.deleted_at IS NULL)").
        order('count(pc.id) DESC')
    when /featured/i
      where(featured: true)
    when /pending/i
      where("(SELECT pc.id from project_collaborators pc WHERE pc.project_id = projects.id AND pc.user_id = 6520 AND ( approved_by_user_at IS NULL OR approved_by_owner_at IS NULL) AND deleted_at IS NULL LIMIT 1) IS NOT NULL")
    else
      if PlatformContext.current.instance.is_community?
        order('projects.followers_count DESC')
      else
        all
      end
    end
  end

  after_commit :user_created_project_event, on: :create, unless: ->(record) { record.draft? }
  def user_created_project_event
    event = :user_created_project
    user = self.creator.try(:object).presence || self.creator
    affected_objects = [user] + self.topics
    ActivityFeedService.create_event(event, self, affected_objects, self)
  end
  after_update :user_created_project_event_on_publish
  def user_created_project_event_on_publish
    if draft_at_changed?
      user_created_project_event
    end
  end

  def to_liquid
    @project_drop ||= ProjectDrop.new(self)
  end

  def draft?
    draft_at.present?
  end

  def enabled?
    draft_at.nil?
  end

  def cover_photo
    photos.first || Photo.new
  end

  def build_new_collaborator
    OpenStruct.new(email: nil)
  end

  def new_collaborators
    (@new_collaborators || []).empty? ? [OpenStruct.new(email: nil)] : @new_collaborators
  end

  def new_collaborators_attributes=(attributes)
    @new_collaborators = (attributes || {}).values.map { |c| c[:email] }.reject(&:blank?).uniq.map { |email| OpenStruct.new(email: email) }
  end

  def trigger_workflow_alert_for_added_collaborators
    return true if @new_collaborators.nil?
    @new_collaborators.each do |collaborator|
      collaborator_email = collaborator.email.try(:downcase)
      next if collaborator_email.blank?
      user = User.find_by(email: collaborator_email)
      next unless user.present?
      unless self.project_collaborators.for_user(user).exists?
        pc = self.project_collaborators.build(user: user, email: collaborator_email, approved_by_owner_at: Time.zone.now)
        pc.save!
        WorkflowStepJob.perform(WorkflowStep::ProjectWorkflow::CollaboratorAddedByProjectOwner, pc.id)
      end
    end
  end


  def restore_photos
    self.photos.only_deleted.where('deleted_at >= ? AND deleted_at <= ?', self.deleted_at - 30.seconds, self.deleted_at + 30.seconds).each do |photo|
      begin
        photo.restore(recursive: true)
      rescue
      end
    end
  end

  def restore_links
    self.links.only_deleted.where('deleted_at >= ? AND deleted_at <= ?', self.deleted_at - 30.seconds, self.deleted_at + 30.seconds).each do |link|
      begin
        link.restore(recursive: true)
      rescue
      end
    end
  end

  def restore_project_collaborators
    self.project_collaborators.only_deleted.where('deleted_at >= ? AND deleted_at <= ?', self.deleted_at - 30.seconds, self.deleted_at + 30.seconds).each do |pc|
      begin
        pc.restore(recursive: true)
      rescue
      end
    end
  end

  # Counter culture does not play along well (on destroy) with acts_as_paranoid
  def fix_counter_caches
    if self.creator && !self.creator.destroyed?
      self.creator.update_column(:projects_count, self.creator.projects.where(draft_at: nil).count)
    end
    true
  end

  # Counter culture does not play along well (on destroy) with acts_as_paranoid
  def fix_counter_caches_after_commit
    execute_after_commit { fix_counter_caches }
    true
  end

  class NotFound < ActiveRecord::RecordNotFound; end
end

