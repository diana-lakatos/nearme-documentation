class Photo < ActiveRecord::Base
  mount_uploader :file, ImageUploader

  belongs_to :workplace

  validates_presence_of :description

  # We'll just make the Photo instance act like the actual
  # uploader
  def method_missing(method, *args, &block)
    super(method, *args, &block)
  rescue NoMethodError
    file.send(method, *args, &block)
  end
end
