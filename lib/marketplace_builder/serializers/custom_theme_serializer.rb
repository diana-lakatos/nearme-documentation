# frozen_string_literal: true
module MarketplaceBuilder
  module Serializers
    class CustomThemeSerializer < BaseSerializer
      resource_name ->(c) { "custom_themes/#{c.name.underscore}" }

      properties :name, :in_use, :in_use_for_instance_admins

      serialize :custom_theme_assets, using: CustomThemeAssetSerializer

      def scope
        CustomTheme.where(instance_id: @model.id).all
      end
    end
  end
end
