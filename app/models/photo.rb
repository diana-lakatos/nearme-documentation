class Photo < ActiveRecord::Base

  include RankedModel
  ranks :position, with_same: [:content_id, :content_type]

  attr_accessible :creator_id, :content_id, :content_type, :caption, :image, :position
  belongs_to :content, :polymorphic => true
  belongs_to :creator, class_name: "User"

  default_scope -> { rank(:position) }
  scope :no_content, -> { where content_id: nil }
  scope :for_listing, -> { where content_type: 'Listing' }

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

  def method_missing(method, *args, &block)
    super(method, *args, &block)
  rescue NoMethodError
    image.send(method, *args, &block)
  end

end
