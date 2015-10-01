class Photo < ActiveRecord::Base

  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  include RankedModel
  has_metadata :without_db_column => true

  ranks :position, with_same: [:transactable_id]

  belongs_to :owner, -> { with_deleted }, polymorphic: true
  belongs_to :creator, -> { with_deleted }, class_name: "User"
  belongs_to :instance

  default_scope -> { rank(:position) }

  validates :image, :presence => true,  :if => lambda { |p| !p.image_original_url.present? }

  validates_length_of :caption, :maximum => 120, :allow_blank => true

  mount_uploader :image, PhotoUploader

  # Don't delete the photo from s3
  skip_callback :commit, :after, :remove_image!

  def listing
    owner_type == 'Transactable' ? owner : nil
  end

  def listing=(object)
    self.owner = object
  end

  after_commit :project_file_added_callback, on: [:create, :update]

  def project_file_added_callback
    if image_changed? && owner.class == Project
      ActivityFeedEvent.create(
        followed: self.owner,
        affected_objects: self.owner.topics.to_a,
        event: :project_file_added
      )
    end
  end

  def image_original_url=(value)
    super
    self.remote_image_url = value
  end

  def original_image_url
    self.image_url(:original)
  end

  def self.xml_attributes
    self.csv_fields.keys
  end

  def self.csv_fields
    { :image_original_url => 'Photo URL' }
  end

end
