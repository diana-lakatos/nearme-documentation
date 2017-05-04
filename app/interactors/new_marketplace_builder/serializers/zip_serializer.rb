module NewMarketplaceBuilder
  module Serializers
    class ZipSerializer
      def initialize(instance, marketplace_release, manifest)
        @marketplace_release = marketplace_release
        @path_serializer = PathSerializer.new(instance, export_folder_path, manifest)
      end

      def serialize(file_to_create, folder, extension)
        @path_serializer.serialize(file_to_create, folder, extension)
      end

      def after_export
        zip_exported_folder
        update_marketplace_release_with_zip
      ensure
        cleanup_after_export
      end

      private

      def zip_exported_folder
        system "cd #{export_folder_path}/#{current_instance_name}; zip -r #{current_instance_name}.zip ."
      end

      def update_marketplace_release_with_zip
        File.open("#{export_folder_path}/#{current_instance_name}/#{current_instance_name}.zip", 'r') do |f|
          @marketplace_release.update! zip_file: f
        end
      end

      def cleanup_after_export
        FileUtils.rm_rf(export_folder_path)
      end

      def current_instance_name
        @current_instance_name ||= PlatformContext.current.instance.name.parameterize
      end

      def export_folder_path
        @export_folder_path ||= "tmp/#{current_instance_name}-#{DateTime.now.to_i}"
      end
    end
  end
end
