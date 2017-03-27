# frozen_string_literal: true
module MarketplaceBuilder
  module Serializers
    class CustomThemeAssetSerializer < BaseSerializer
      properties :name
      property :remote_url

      def remote_url(asset)
        asset.file.proper_file_path
      end

      def scope
        @model.custom_theme_assets
      end
    end
  end
end
