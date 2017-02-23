# frozen_string_literal: true
module MarketplaceBuilder
  module Creators
    class CustomThemesCreator < DataCreator
      def execute!
        custom_themes = get_data

        custom_themes.each do |_key, custom_theme_attributes|
          custom_theme = CustomTheme.where(name: custom_theme_attributes['name']).first_or_initialize
          custom_theme.assign_attributes custom_theme_attributes.merge(themeable: @instance)
          custom_theme.save!

          import_assets(custom_theme)
        end
      end

      private

      def import_assets(custom_theme)
        Dir.glob("#{File.join(@theme_path, source)}/#{custom_theme.name.underscore}_custom_theme_assets/*.*") do |asset_file|
          File.open(asset_file) do |file|
            custom_theme.custom_theme_assets.where(type: type_by_file_path(asset_file), name: File.basename(asset_file)).first_or_create(file: file)
          end
        end
      end

      def type_by_file_path(asset_file_path)
        case File.extname(asset_file_path).downcase
          when '.css' then 'CustomThemeAsset::ThemeCssFile'
          when '.js' then 'CustomThemeAsset::ThemeJsFile'
          when /.jpg|.png|.jpeg|.gif|.svg/ then 'CustomThemeAsset::ThemeImageFile'
          when /.eot|.ttf|.woff|.woff2/ then 'CustomThemeAsset::ThemeFontFile'
          else 'CustomThemeAsset::ThemeFile'
        end
      end

      def source
        File.join('custom_themes')
      end
    end
  end
end
