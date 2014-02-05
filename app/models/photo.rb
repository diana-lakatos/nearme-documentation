class Photo < ActiveRecord::Base
  has_paper_trail

  include RankedModel
  include Metadata

  ranks :position, with_same: [:listing_id]

  attr_accessible :creator_id, :listing_id, :caption, :image, :image_versions_generated_at, :image_transformation_data, :position
  belongs_to :listing
  belongs_to :creator, class_name: "User"

  default_scope -> { rank(:position) }

  acts_as_paranoid

  delegate :populate_photos_metadata!, :to => :listing, :prefix => true

  after_commit :listing_populate_photos_metadata!, :if => lambda { |p| p.should_populate_metadata? }
  after_commit :update_counter!

  validates :image, :presence => true,  :if => lambda { |p| !p.image_original_url.present? }

  validates_length_of :caption, :maximum => 120, :allow_blank => true

  extend CarrierWave::SourceProcessing
  mount_uploader :image, PhotoUploader, :use_inkfilepicker => true

  # Don't delete the photo from s3
  skip_callback :commit, :after, :remove_image!

  def should_populate_metadata?
    deleted? || (listing.present? && relevant_attribute_changed?)
  end

  def relevant_attribute_changed?
    %w(deleted_at caption position listing_id image crop_x crop_y crop_h crop_w rotation_angle image_original_url image_transformation_data).any? do |attr| 
      metadata_relevant_attribute_changed?(attr) 
    end
  end

  def to_listing_metadata
    { 
      space_listing: image_url(:space_listing),
      golden:  image_url(:golden) ,
      large: image_url(:large),
    }
  end

  def to_location_metadata
    to_listing_metadata.merge(listing_name: listing.name, caption: caption)
  end

  private

  def update_counter!
    listing.reload.update_column(:photos_count, listing.photos.count) if listing.present?
  end


end
