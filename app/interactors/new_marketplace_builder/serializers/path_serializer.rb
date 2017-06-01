module NewMarketplaceBuilder
  module Serializers
    class PathSerializer
      def initialize(instance, destination_path, manifest)
        @instance = instance
        @destination_path = destination_path
        @manifest = manifest
      end

      def serialize(file_to_create, folder, extension)
        ensure_directory_exist! "#{folder}/#{file_to_create[:resource_name]}"
        return create_theme_files!(file_to_create) if extension == 'theme_with_assets'

        create_file_with_content! file_to_create, folder, extension
      end

      def after_export
      end

      private

      def create_file_with_content!(file, folder, extension)
        file = parse_liquid_file(file) if extension == 'liquid'
        file = parse_graphql_file(file) if extension == 'graphql'
        file_path = "#{@destination_path}/#{instance_name}/#{folder}/#{file[:resource_name]}.#{extension}"

        File.open(file_path, 'w') do |f|
          raw_content = file[:exported_data].delete('body') || file[:exported_data].delete('content')
          file[:exported_data].delete('view_type') if file[:exported_data]['view_type'] == 'view'

          if file[:exported_data].present?
            f.write file[:exported_data].deep_stringify_keys.to_yaml
            f.puts '---' if raw_content.present?
          end
          f.write raw_content
        end

        update_md5_for_file file_path
      end

      def create_theme_files!(exported_hash)
        custom_theme_assets = exported_hash[:exported_data].delete('custom_theme_assets')
        create_file_with_content! exported_hash, 'custom_themes', 'yml'

        FileUtils.mkdir_p "#{@destination_path}/#{instance_name}/custom_themes/#{exported_hash[:resource_name]}_custom_theme_assets/"
        create_assets!(exported_hash[:resource_name], custom_theme_assets) if custom_theme_assets
      end

      def create_assets!(theme_name, custom_theme_assets)
        custom_theme_assets.each do |asset|
          download_and_save_asset(theme_name, asset)
        end
      end

      def download_and_save_asset(theme_name, asset)
        open(asset['remote_url']) do |downloaded_asset|
          file_path = "#{@destination_path}/#{instance_name}/custom_themes/#{theme_name}_custom_theme_assets/#{asset['name']}"
          ensure_directory_exist!("custom_themes/#{theme_name}_custom_theme_assets/#{asset['name']}")
          IO.copy_stream(downloaded_asset, file_path)
          update_md5_for_file(file_path)
        end
      rescue OpenURI::HTTPError => e
        puts "Error while downloading #{asset['remote_url']} status: #{e.io.status}"
      rescue StandardError => e
        puts "Error: #{e.message}"
        Raygun.track_exception(e) if !Rails.env.development?
      end

      def ensure_directory_exist!(file_path)
        dir_path = File.dirname file_path
        FileUtils.mkdir_p "#{@destination_path}/#{instance_name}/#{dir_path}"
      end

      def update_md5_for_file(file_path)
        File.open(file_path, 'r') do |f|
          builder_file_md5 = Digest::MD5.hexdigest f.read
          @manifest.set_md5(file_path.gsub("#{@destination_path}/#{instance_name}", ''), builder_file_md5)
        end
      end

      def parse_liquid_file(file)
        file[:exported_data].delete('partial')
        file[:exported_data].delete('path')
        file
      end

      def parse_graphql_file(file)
        file[:exported_data].delete('name')
        file
      end

      def instance_name
        @instance_name ||= @instance.name.parameterize
      end
    end
  end
end
