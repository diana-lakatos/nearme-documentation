# frozen_string_literal: true
module CategoriesOwnerable
  extend ActiveSupport::Concern
  included do
    has_many :categories_categorizables, as: :categorizable
    has_many :categories, through: :categories_categorizables

    # FIXME: nead a cleaner solution - for now it's used by Form Object
    # to populate inputs
    def categories_open_struct
      hash = {}
      custom_attribute_target.categories.roots.includes(:children).find_each do |category|
        hash[category.name] = categories.select { |c| c.permalink =~ /^#{category.permalink}/ }
      end
      OpenStruct.new(hash)
    end

    # FIXME: nead a cleaner solution - for now it's used by Form Object
    # to sync model with form after validation passes
    def categories_open_struct=(open_struct)
      hash = categories_open_struct.to_h.each_with_object({}) do |(category_name, values), ids_hash|
        # if form does not include all categories, we don't want to nullify them.
        # i.e. if there are categories A and B, user has both filled, but then
        # submits a form which allows to update only B, then A should stay
        ids_hash[category_name] = open_struct[category_name] || values
      end
      self.category_ids = hash.values.flatten.reject(&:blank?).map(&:to_i)
    end
  end
end
