# frozen_string_literal: true
module TransactablesOwnerable
  extend ActiveSupport::Concern
  included do
    # FIXME: nead a cleaner solution - for now it's used by Form Object
    # to populate inputs
    def transactables_open_struct
      hash = {}
      TransactableType.pluck(:name, :id).each do |transactable_types_array|
        hash[transactable_types_array[0]] = transactables.select { |c| c.transactable_type_id == transactable_types_array[1] }
      end
      OpenStruct.new(hash)
    end

    # FIXME: nead a cleaner solution - for now it's used by Form Object
    # to sync model with form after validation passes
    def transactables_open_struct=(open_struct)
      trs = open_struct.to_h.values.flatten
      self.transactables = trs
    end
  end
end
