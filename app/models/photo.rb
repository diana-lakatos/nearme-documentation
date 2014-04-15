class Photo < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid

  include RankedModel
  has_metadata :without_db_column => true

  ranks :position, with_same: [:transactable_id]

  belongs_to :listing, class_name: "Transactable", foreign_key: 'transactable_id'
  belongs_to :creator, class_name: "User"
  attr_accessible :creator_id, :transactable_id, :caption, :image, :image_versions_generated_at, :image_transformation_data, :position

  default_scope -> { rank(:position) }

  validates :image, :presence => true,  :if => lambda { |p| !p.image_original_url.present? }

  validates_length_of :caption, :maximum => 120, :allow_blank => true

  extend CarrierWave::SourceProcessing
  mount_uploader :image, PhotoUploader, :use_inkfilepicker => true

  # Don't delete the photo from s3
  skip_callback :commit, :after, :remove_image!

end
