Spree::Image.class_eval do

  extend CarrierWave::SourceProcessing
  mount_uploader :image, SpreePhotoUploader

  # Don't delete the photo from s3
  skip_callback :commit, :after, :remove_image!

  _validators.reject!{ |key, _| [:attachment].include?(key) }
  _validate_callbacks.reject! do |callback|
    callback.raw_filter.attributes.delete :attachment if callback.raw_filter.is_a?(ActiveModel::Validations::PresenceValidator)
  end
end
