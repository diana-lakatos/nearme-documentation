class Photo < ActiveRecord::Base

  attr_accessible :content_id, :caption, :image, :position
  belongs_to :content, :polymorphic => true

  acts_as_paranoid
  validates :image, :presence => true
  validates_presence_of :caption

  mount_uploader :image, PhotoUploader

  def method_missing(method, *args, &block)
    super(method, *args, &block)
  rescue NoMethodError
    image.send(method, *args, &block)
  end

end
