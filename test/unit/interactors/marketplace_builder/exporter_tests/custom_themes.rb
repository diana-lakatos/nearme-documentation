require_relative 'basic'

module MarketplaceBuilder
  module ExporterTests
    class ShouldExportCustomThemes < Basic
      def initialize(instance)
        @instance = instance
      end

      def seed!
        File.open("#{Rails.root}/tmp/main.js", 'w+') { |f| f.puts 'js content' }

        custom_theme = @instance.custom_themes.create! name: 'Default', in_use: false, in_use_for_instance_admins: true
        custom_theme.custom_theme_assets.create! name: 'main.js', file: File.open("#{Rails.root}/tmp/main.js"), type: 'CustomThemeAsset::ThemeJsFile'
      end

      def execute!
        yaml_content = read_exported_file('custom_themes/default.yml')
        assert_equal yaml_content, 'name' => 'Default', 'in_use' => false, 'in_use_for_instance_admins' => true

        js_content = read_exported_file('custom_themes/default_custom_theme_assets/main.js')
        assert_equal js_content, 'js content'
      end
    end
  end
end
