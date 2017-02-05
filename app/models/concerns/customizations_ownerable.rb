# frozen_string_literal: true
module CustomizationsOwnerable
  extend ActiveSupport::Concern
  included do
    has_many :customizations, as: :customizable

    # FIXME: nead a cleaner solution - for now it's used by Form Object
    # to populate inputs
    def customizations_open_struct
      hash = {}
      custom_attribute_target.custom_model_types.pluck(:name, :id).each do |custom_model_type_array|
        hash[custom_model_type_array[0]] = customizations.select { |c| c.custom_model_type_id == custom_model_type_array[1] }
      end
      OpenStruct.new(hash)
    end

    # FIXME: nead a cleaner solution - for now it's used by Form Object
    # to sync model with form after validation passes
    def customizations_open_struct=(open_struct)
      hash = customizations_open_struct.to_h.each_with_object({}) do |(custom_model_name, values), ids_hash|
        # if form does not include all customizations, we don't want to nullify them.
        # i.e. if there are customizations A and B, user has both filled, but then
        # submits a form which allows to update only B, then A should stay
        ids_hash[custom_model_name] = open_struct[custom_model_name]&.reject(&:marked_for_destruction?) || values
      end
      self.customizations = hash.values.flatten.compact
    end
  end
end
