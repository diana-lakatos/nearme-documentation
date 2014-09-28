Spree::Image.class_eval do

  extend CarrierWave::SourceProcessing
  mount_uploader :image, SpreePhotoUploader

  # Don't delete the photo from s3
  skip_callback :commit, :after, :remove_image!

  after_save do |i|
    if i.reload.attachment.exists?
      i.image = File.open(i.attachment.path(:original), 'rb')
      i.save
    end
  end
end
