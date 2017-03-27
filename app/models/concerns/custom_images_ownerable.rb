# frozen_string_literal: true
module CustomImagesOwnerable
  extend ActiveSupport::Concern
  included do
    has_many :custom_images, as: :owner

    # FIXME: nead a cleaner solution - for now it's used by Form Object
    # to populate inputs
    def custom_images_open_struct
      nil
    end

    def default_images_open_struct
      hash = {}
      custom_attribute_target.custom_attributes.where(attribute_type: 'photo').pluck(:id).each do |id|
        hash[id.to_s] = custom_images.detect { |ci| ci.custom_attribute_id == id }.tap do |ci|
          ci&.owner_type = self.class.name
        end
      end
      OpenStruct.new(hash)
    end

    # FIXME: nead a cleaner solution - for now it's used by Form Object
    # to sync model with form after validation passes
    def custom_images_open_struct=(open_struct)
      open_struct.to_h.each do |ca_id, ci|
        next if ci.nil?
        custom_image = if ci.id.present? && ci.owner.blank?
                         CustomImage.where(id: ci.id, owner_type: nil, owner_id: nil, uploader_id: nil).first
                       elsif ci.id.blank? && ci.owner.blank?
                         CustomImage.where(custom_attribute_id: ca_id.to_s, owner_type: nil, owner_id: nil, uploader_id: nil, created_at: ci.created_at, image: ci.read_attribute(:image)).first
                       end
        custom_images << custom_image if custom_image.present?
      end
      custom_images
    end
  end
end
