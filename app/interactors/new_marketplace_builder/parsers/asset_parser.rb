module NewMarketplaceBuilder
  module Parsers
    class AssetParser
      def initialize(raw_source, file_path)
        @raw_source = raw_source
        @file_path = file_path
      end

      def parse
        { 'name' => asset_name, 'body' => @raw_source }
      end

      private

      def asset_name
        @file_path.split('/default_custom_theme_assets/').last
      end
    end
  end
end
