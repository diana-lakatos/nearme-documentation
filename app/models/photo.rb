class Photo < ActiveRecord::Base

  attr_accessible :content_id, :content_type, :caption, :image, :position
  belongs_to :content, :polymorphic => true

  acts_as_paranoid

  # Don't delete the photo from s3
  skip_callback :destroy, :after, :remove_image!

  validates :image, :presence => true

  mount_uploader :image, PhotoUploader

  def method_missing(method, *args, &block)
    super(method, *args, &block)
  rescue NoMethodError
    image.send(method, *args, &block)
  end

end
