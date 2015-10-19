class Project < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context
  has_custom_attributes target_type: 'ProjectType', target_id: :transactable_type_id

  attr_reader :collaborator_email
  attr_readonly :followers_count

  DEFAULT_ATTRIBUTES = %w(name description)
  SORT_OPTIONS = ['All', 'Featured', 'Most Recent', 'Most Popular', 'Contributors']

  belongs_to :creator, -> { with_deleted }, class_name: "User", inverse_of: :projects, counter_cache: true
  belongs_to :transactable_type, -> { with_deleted }, foreign_key: 'transactable_type_id'

  has_many :activity_feed_events, as: :event_source, dependent: :destroy
  has_many :activity_feed_subscriptions, as: :followed
  has_many :approved_project_collaborators, -> { approved }, class_name: 'ProjectCollaborator'
  has_many :comments, as: :commentable
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
  has_many :project_collaborators
  has_many :project_topics
  has_many :topics, through: :project_topics
  has_many :user_messages, as: :thread_context, inverse_of: :thread_context
  has_many :wish_list_items, as: :wishlistable

  scope :by_topic, -> (topic_ids) { includes(:topics).where(topics: {id: topic_ids}) if topic_ids.present?}
  scope :seek_collaborators, -> { where(seek_collaborators: true) }
  scope :featured, -> { where(featured: true) }
  scope :by_search_query, lambda { |query|
    where("name ilike ? or description ilike ? or summary ilike ?", query, query, query)
  }
  scope :with_date, ->(date) { where(created_at: date) }

  accepts_nested_attributes_for :photos, allow_destroy: true
  accepts_nested_attributes_for :links, reject_if: :all_blank, allow_destroy: true

  attr_accessor :photo_not_required

  validates :photos, length: {minimum: 1}, unless: ->(record) { record.photo_not_required || !record.transactable_type.enable_photo_required }
  validates :topics, length: {:minimum => 1}
  validates :summary, length: { maximum: 140 }
  validates_presence_of :name

  # TODO: move to form object
  after_save :trigger_workflow_alert_for_added_collaborators

  before_restore :restore_photos
  before_restore :restore_links

  def self.featured
    where(featured: true)
  end

  def self.custom_order(order)
    case order
    when /most recent/i
      order('projects.created_at DESC')
    when /most popular/i
      #TODO check most popular sort after followers are implemented
      order('projects.followers_count DESC')
    when /contributors/i
      group('projects.id').
        joins("LEFT OUTER JOIN project_collaborators pc ON projects.id = pc.project_id AND (pc.approved_at IS NOT NULL AND pc.deleted_at IS NULL)").
        order('count(pc.id) DESC')
    when /featured/i
      where(featured: true)
    else
      all
    end
  end

  after_commit :user_created_project_event, on: :create
  def user_created_project_event
    event = :user_created_project
    affected_objects = [self.creator] + self.topics
    ActivityFeedService.create_event(event, self, affected_objects, self)
  end

  after_commit :user_added_photos_to_project_event, on: :update
  def user_added_photos_to_project_event
    if self.photos.map(&:id_changed?)
      event = :user_added_photos_to_project
      ActivityFeedService.create_event(event, self, [self.creator], self)
    end
  end

  after_commit :user_added_links_to_project_event, on: :update
  def user_added_links_to_project_event
    if self.links.map(&:id_changed?)
      event = :user_added_links_to_project
      ActivityFeedService.create_event(event, self, [self.creator], self)
    end
  end

  def to_liquid
    @project_drop ||= ProjectDrop.new(self)
  end

  def self.search_by_query(attributes = [], query)
    if query.present?
      words = query.split.map.with_index{|w, i| ["word#{i}".to_sym, "%#{w}%"]}.to_h

      sql = attributes.map do |attrib|
        attrib = "#{quoted_table_name}.\"#{attrib}\""
        words.map do |word, value|
          "#{attrib} ILIKE :#{word}"
        end
      end.flatten.join(' OR ')

      where(ActiveRecord::Base.send(:sanitize_sql_array, [sql, words]))
    else
      all
    end
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
      collaborator_email = collaborator.email
      next if collaborator_email.blank?
      user = User.find_by(email: collaborator_email)
      next unless user.present?
      unless self.project_collaborators.where(user: user).exists?
        WorkflowStepJob.perform(WorkflowStep::ProjectWorkflow::CollaboratorAddedByProjectOwner, self.project_collaborators.create!(user: user, approved_at: Time.zone.now).id)
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

  class NotFound < ActiveRecord::RecordNotFound; end
end

