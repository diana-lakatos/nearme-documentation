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

  after_commit :enqueue_processing, on: :create

  def should_generate_versions?
    self.persisted?
  end

  def generate_versions
    self.versions_generated = true
    image.recreate_versions! :thumb, :large, :space_listing, :golden
    save!
  end

  def method_missing(method, *args, &block)
    super(method, *args, &block)
  rescue NoMethodError
    image.send(method, *args, &block)
  end

  # hack, after adding recreate_versions! for some reason you can't access file via photo.url(:version) anymore!
  # however, I have noticed that photo.<version> works as expected
  def url(version)
    send(version)
  end

  private

  # We enqueue a processing job for after we've created and saved the photo.
  # This enables us to control when the processing ocurrs.
  def enqueue_processing
    PhotoImageProcessJob.perform(id)
  end

end
