# frozen_string_literal: true
module NewMarketplaceBuilder
  module Converters
    class CustomThemeAssetConverter < BaseConverter
      primary_key :name
      properties :name
      property :remote_url

      def remote_url(asset)
        asset.file.proper_file_path
      end

      def import(assets)
        assets.each do |asset|
          custom_theme_asset = custom_theme_asset_by_name(asset['name'])
          custom_theme_asset = build_file(custom_theme_asset, asset['body']) unless asset['body'].nil?

          ActiveRecord::Base.logger.silence do
            custom_theme_asset.save!
            Rails.logger.info "[SQL] Saving custom theme assset #{custom_theme_asset.name} (SQL log disabled for performance reason)."
          end
        end
      end

      def scope
        CustomTheme.find_by(name: 'Default').try(:custom_theme_assets) || CustomThemeAsset.none
      end

      private

      def build_file(custom_theme_asset, body)
        tmp_file = Tempfile.new('tmp_file')
        tmp_file.binmode
        tmp_file << body
        tmp_file.rewind
        file_params = {
          filename: custom_theme_asset.name,
          tempfile: tmp_file
        }
        custom_theme_asset.file = ActionDispatch::Http::UploadedFile.new(file_params)
        custom_theme_asset
      end

      def custom_theme_asset_by_name(name)
        CustomTheme.find_by(name: 'Default').custom_theme_assets.where(
          type: type_by_file_path(name),
          name: name.gsub('/custom_themes/default_custom_theme_assets/', '')
        ).first_or_initialize
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
    end
  end
end
