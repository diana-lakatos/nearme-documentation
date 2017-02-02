# frozen_string_literal: true
require 'open-uri'

namespace :migrate_ckeditor_assets do
  SPACER_ISNTANCE_ID = 130
  ASSEET_REGEX = '"http[^"]+\/instances\/[^"]+\/ckeditor\/[^"]+"'

  task scan_and_save_asset_urls: :environment do
    Instance.find(SPACER_ISNTANCE_ID).set_context!
    founded_assets = []

    ContentHolder.all.each do |content_holder|
      founded_assets.concat content_holder.content.scan Regexp.new(ASSEET_REGEX)
    end

    InstanceView.where("body ~* ?", ASSEET_REGEX).each do |instance_view|
      founded_assets.concat instance_view.body.scan Regexp.new(ASSEET_REGEX)
    end

    Page.where("html_content ~* ?", ASSEET_REGEX).each do |page_view|
      founded_assets.concat page_view.html_content.scan Regexp.new(ASSEET_REGEX)
    end

    File.open('tmp/ckeditor_assets.txt', 'w') {|f| f.puts founded_assets.uniq }
  end

  task download_and_convert_assets: :environment do
    FileUtils.rm_rf 'tmp/ckeditor_assets/'
    FileUtils.mkdir_p 'tmp/ckeditor_assets/'

    CkEditorAssetsConverter.new.download_and_convert!
  end

  class CkEditorAssetsConverter
    def download_and_convert!
      assets_array.each do |asset_path|
        puts "Downloading #{asset_path}"
        begin
          open(asset_path) do |downloaded_asset|
            IO.copy_stream(downloaded_asset, "tmp/ckeditor_assets/#{new_file_name(asset_path)}")
          end
        rescue OpenURI::HTTPError => e
          puts "Error while downloading #{asset_path} status: #{e.io.status}"
        end
      end
    end

    private

    def assets_array
      @assets_array ||= File.read('tmp/ckeditor_assets.txt').gsub('"', '').split("\n")
    end

    def file_names_array
      @file_names_array = assets_array.map { |asset_path| file_name_from_path(asset_path) }
    end

    def new_file_name(asset_path)
      path_file_name = file_name_from_path(asset_path)

      if file_names_array.count {|f| f == path_file_name } == 1
        path_file_name
      else
        "#{file_id_from_path(asset_path)}-#{path_file_name}"
      end
    end

    def file_name_from_path(asset_path)
      uri = URI.parse(asset_path)
      File.basename(uri.path)
    end

    def file_id_from_path(asset_path)
      asset_path.split('/').last(2).first
    end
  end

  task scan_liquids_and_replace_assets: :environment do
    Instance.find(SPACER_ISNTANCE_ID).set_context!
    CkEditorAssetsMigrator.new.scan_and_replace!
  end

  class CkEditorAssetsMigrator
    def scan_and_replace!
      ContentHolder.all.each do |content_holder|
        founded_assets = content_holder.content.scan Regexp.new(ASSEET_REGEX)
        content_holder.update! content: replace_assets(founded_assets, content_holder.content)
      end

      InstanceView.where("body ~* ?", ASSEET_REGEX).each do |instance_view|
        founded_assets = instance_view.body.scan Regexp.new(ASSEET_REGEX)
        instance_view.body = replace_assets(founded_assets, instance_view.body)
        instance_view.save(validate: false)
      end

      Page.where("html_content ~* ?", ASSEET_REGEX).each do |page_view|
        founded_assets = page_view.html_content.scan Regexp.new(ASSEET_REGEX)
        page_view.update! html_content: replace_assets(founded_assets, page_view.html_content)
      end
    end

    private

    def replace_assets(founded_assets, source)
      founded_assets.each do |asset|
        helper_as_string = asset_helper_string(asset)
        source.gsub!(asset, helper_as_string) if helper_as_string
      end

      source
    end

    def asset_helper_string(asset)
      id, name = asset.gsub('"', '').split('/').last(2)

      asset_by_name_present = CustomThemeAsset.exists?(name: name)
      asset_by_id_and_name_present = CustomThemeAsset.exists?(name: "#{id}-#{name}")

      if asset_by_name_present
        "\"{{asset_url['#{name}']}}\""
      elsif asset_by_id_and_name_present
        "\"{{asset_url['#{id}-#{name}']}}\""
      end
    end
  end
end
