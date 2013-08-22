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

  # We handle processing of image versions if the 'versions_generated' flag is
  # false. This is the case on initial upload, or when adjustments are applied
  # by the User.
  after_commit :enqueue_processing, unless: :versions_generated

  # The PhotoUploader tests the Photo for this predicate to determine whether
  # it should execute version generation for some versions.
  #
  # This should be the case when versions are ready to be regenerated, but not
  # in the case of a request/response cycle so that we can handle the generation
  # in the background.
  def should_create_versions!
    @should_create_versions = true
  end

  def should_generate_versions?
    @should_create_versions
  end

  # Executes generating the image versions and flags the Photo accordingly.
  def generate_versions
    should_create_versions!
    image.recreate_versions!
    self.versions_generated = true
    save!(validate: false)
  end

  def apply_adjustments(adjustments)
    return true unless adjustments[:crop] or adjustments[:rotate]
    self.crop_params = adjustments[:crop] if adjustments[:crop]
    self.rotation_angle = adjustments[:rotate]

    # Regenerate any relevant versions that need to be handled immediately
    self.recreate_versions!

    # Reset the 'versions generated' state so that the various versions of this
    # image can be re-generated based on the modifications.
    self.versions_generated = false
    save!
  end

  def crop_params=(crop_params)
    %w(x y w h).each { |param| send("crop_#{param}=", crop_params[param]) }
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
