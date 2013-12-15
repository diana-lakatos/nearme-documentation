class Photo < ActiveRecord::Base

  include RankedModel

  ranks :position, with_same: [:listing_id]

  attr_accessible :creator_id, :listing_id, :caption, :image, :image_versions_generated_at, :image_transformation_data, :position 
  belongs_to :listing, counter_cache: true
  belongs_to :creator, class_name: "User"

  default_scope -> { rank(:position) }
  
  acts_as_paranoid

  after_create :notify_user_about_change
  after_destroy :notify_user_about_change
  delegate :notify_user_about_change, :to => :listing, :allow_nil => true

  # Don't delete the photo from s3
  skip_callback :destroy, :after, :remove_image!

  validates :image, :presence => true,  :if => lambda { |p| !p.image_original_url.present? }

  validates_length_of :caption, :maximum => 120, :allow_blank => true

  extend CarrierWave::SourceProcessing
  mount_uploader :image, PhotoUploader, :use_inkfilepicker => true

end
