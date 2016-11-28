# frozen_string_literal: true
module CustomImagesOwnerable
  extend ActiveSupport::Concern
  included do
    has_many :custom_images, as: :owner

    # FIXME: nead a cleaner solution - for now it's used by Form Object
    # to populate inputs
    def custom_images_open_struct
      hash = {}
      custom_attribute_target.custom_attributes.where(attribute_type: 'photo').pluck(:id).each do |id|
        hash[id.to_s] = custom_images.detect { |ci| ci.custom_attribute_id == id }
      end
      OpenStruct.new(hash)
    end

    # FIXME: nead a cleaner solution - for now it's used by Form Object
    # to sync model with form after validation passes
    def custom_images_open_struct=(open_struct)
      hash = custom_images_open_struct.to_h.each_with_object({}) do |(ca_id, custom_image), ids_hash|
        # if form does not include all custom images, we don't want to nullify them.
        # i.e. if there are custom images A and B, user has both filled, but then
        # submits a form which allows to update only B, then A should stay
        ids_hash[ca_id] = open_struct[ca_id].tap { |i| i.owner = self if i.new_record? } || custom_image
      end
      self.custom_images = hash.values.flatten
    end
  end
end
