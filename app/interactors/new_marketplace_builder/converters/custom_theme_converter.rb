# frozen_string_literal: true
module NewMarketplaceBuilder
  module Converters
    class CustomThemeConverter < BaseConverter
      primary_key :name
      properties :name, :in_use, :in_use_for_instance_admins

      convert :custom_theme_assets, using: CustomThemeAssetConverter

      def scope
        CustomTheme.where(instance_id: @model.id)
      end

      def default_values(_)
        {
          themeable_id: @model.id,
          themeable_type: @model.class.to_s
        }
      end
    end
  end
end
