Spree::Image.class_eval do
  include Spree::Scoper
  include RankedModel
  extend CarrierWave::SourceProcessing
  mount_uploader :image, SpreePhotoUploader, use_inkfilepicker: true

  # Don't delete the photo from s3
  skip_callback :commit, :after, :remove_image!

  ranks :position, with_same: [:viewable_id, :viewable_type]
  default_scope -> { rank(:position) }

  _validators.reject!{ |key, _| [:attachment].include?(key) }
  _validate_callbacks.reject! do |callback|
    callback.raw_filter.attributes.delete :attachment if callback.raw_filter.is_a?(ActiveModel::Validations::PresenceValidator)
  end
end
