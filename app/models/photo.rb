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

  after_commit :enqueue_processing, unless: :versions_generated

  def should_generate_versions?
    persisted? and not versions_generated
  end

  def generate_versions
    image.recreate_versions! :thumb, :large, :space_listing, :golden
    self.versions_generated = true
    save!
  end

  def apply_adjustments(adjustments)
    return true unless adjustments[:crop] or adjustments[:rotate]
    self.crop_params = adjustments[:crop] if adjustments[:crop]
    self.rotation_angle = adjustments[:rotate]
    self.recreate_versions! # only medium and adjusted versions will be created because versions_generated is true
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
