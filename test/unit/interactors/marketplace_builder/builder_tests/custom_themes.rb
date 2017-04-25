module MarketplaceBuilder
  module BuilderTests
    class ShouldImportCustomThemes < ActiveSupport::TestCase
      def initialize(instance)
        @instance = instance
        @custom_theme = @instance.custom_themes.first
        @custom_asset = @custom_theme.custom_theme_assets.first
      end

      def execute!
        compare_custom_theme
        compare_custom_theme_assets
      end

      private

      def compare_custom_theme
        assert_equal 1, @instance.custom_themes.count

        assert_equal @custom_theme.name, 'Default'
        assert_equal @custom_theme.in_use, false
        assert_equal @custom_theme.in_use_for_instance_admins, false
      end

      def compare_custom_theme_assets
        assert_equal 1, @custom_theme.custom_theme_assets.count

        assert_equal @custom_asset.name, 'application.css'
        assert_equal @custom_asset.type, 'CustomThemeAsset::ThemeCssFile'
        assert_includes @custom_asset.file.read, 'h1 { font-size: 100px }'
      end
    end
  end
end
