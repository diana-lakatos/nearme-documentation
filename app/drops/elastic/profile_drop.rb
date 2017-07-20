# frozen_string_literal: true
module Elastic
  class ProfileDrop < BaseDrop
    delegate :id, :properties, :categories, :onboarded_at, :profile_type, :enabled, to: :source

    # @return [Hash{String => Hash}] hash of availability template
    # {
    #   availability_rules: [{ .. }],
    #   schedule_exception_rules: [{ .. }],
    # }
    def availability_template
      @source.availability_template
    end

    # @return [Hash{String => Array}] hash of customizations grouped by custom model type name
    def grouped_customizations
      source.customizations
            .map { |customization| Elastic::CustomizationDrop.new(customization) }
            .group_by(&:name)
    end
    alias customizations grouped_customizations

    def custom_images
      source.custom_images.each_with_object({}) do |img, group|
        group[img.name] = img
      end
    end
    alias grouped_custom_images custom_images

    def category_tree
      source.category_list.sort(&:position).group_by(&:name_of_root)
    end
  end
end
