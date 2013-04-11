class Photo < ActiveRecord::Base

  attr_accessible :creator_id, :content_id, :content_type, :caption, :image, :position
  belongs_to :content, :polymorphic => true
  belongs_to :creator, class_name: "User"

  acts_as_paranoid

  # Don't delete the photo from s3
  skip_callback :destroy, :after, :remove_image!

  validates :image, :presence => true
  validates :content_type, :presence => true
  validates_length_of :caption, :maximum => 120, :allow_blank => true

  mount_uploader :image, PhotoUploader

  def method_missing(method, *args, &block)
    super(method, *args, &block)
  rescue NoMethodError
    image.send(method, *args, &block)
  end

end
