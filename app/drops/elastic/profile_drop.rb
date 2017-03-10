module Elastic
  class ProfileDrop < BaseDrop
    delegate :properties, :categories, to: :source

  # @return [Hash{String => Array}] hash of customizations grouped by custom model type name
    def grouped_customizations
      source.customizations.group_by(&:name)
    end

    def custom_images
      source.custom_images.each_with_object({}) do |img, group|
        group[img.name] = img
      end
    end
    alias grouped_custom_images custom_images

    def category_tree
      source.categories.sort(&:position).group_by(&:root)
    end
  end
end
