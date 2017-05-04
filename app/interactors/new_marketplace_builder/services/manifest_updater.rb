module NewMarketplaceBuilder
  module Services
    class ManifestUpdater
      def initialize(instance)
        @instance = instance
      end

      def get_md5(path)
        manifest[path].try(:[], 'md5')
      end

      def set_md5(path, md5)
        manifest[path] = {} if manifest[path].nil?
        manifest[path]['md5'] = md5
      end

      def update_md5
        @instance.marketplace_builder_settings.update! manifest: manifest
      end

      def remove_outdated_paths(used_paths)
        manifest.reject! {|path, _| used_paths.exclude? path }
      end

      private

      def manifest
        @manifest ||= @instance.marketplace_builder_settings.manifest
      end
    end
  end
end
