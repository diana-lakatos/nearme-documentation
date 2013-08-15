class Photo < ActiveRecord::Base

  include RankedModel
  ranks :position, with_same: [:content_id, :content_type]

  attr_accessible :creator_id, :content_id, :content_type, :caption, :image, :position
  belongs_to :content, :polymorphic => true
  belongs_to :creator, class_name: "User"

  default_scope -> { rank(:position) }
  scope :no_content, -> { where content_id: nil }
  scope :for_listing, -> { where content_type: 'Listing' }
  scope :ready, -> { where(versions_generated: true) }

  acts_as_paranoid

  after_create :notify_user_about_change
  after_destroy :notify_user_about_change

  # Don't delete the photo from s3
  skip_callback :destroy, :after, :remove_image!

  delegate :notify_user_about_change, :to => :content, :allow_nil => true

  validates :image, :presence => true
  validates :content_type, :presence => true
  validates_length_of :caption, :maximum => 120, :allow_blank => true

  mount_uploader :image, PhotoUploader

  AVAILABLE_CONTENT = ['Listing', 'Location']

  before_create :disable_processing # Handle processing after saving the image
  after_commit :enqueue_processing, on: :create

  def generate_versions
    image.recreate_versions!
    self.versions_generated = true
    save!
  end

  def method_missing(method, *args, &block)
    super(method, *args, &block)
  rescue NoMethodError
    image.send(method, *args, &block)
  end

  private

  # We disable processing so that CarrierWave doesn't generate and upload
  # our specified versions.
  def disable_processing
    image.enable_processing = false
    true
  end

  # We enqueue a processing job for after we've created and saved the photo.
  # This enables us to control when the processing ocurrs.
  def enqueue_processing
    PhotoImageProcessJob.perform(id)
  end

end
