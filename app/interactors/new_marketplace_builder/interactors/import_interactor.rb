module NewMarketplaceBuilder
  module Interactors
    class ImportInteractor
      def initialize(instance_id, source, options = {})
        @instance_id = instance_id
        @source = source
        @force_mode = options["force_mode"] == "true"
      end

      def execute!
        instance.set_context!
        manifest_updater.clear_manifest if @force_mode
        manifest_updater.remove_outdated_paths builder_file_paths if should_remove_models

        grouped_builder_files.each do |pattern, builder_files|
          ResourceImporter.new(instance, manifest_updater, converters_config, pattern, builder_files, should_remove_models).call
        end

        manifest_updater.update_md5
      end

      private

      def grouped_builder_files
        @grouped_builder_files ||= Services::ImportFilesMatcher.new(reader, converters_config).group_files_by_patterns
      end

      def reader
        @reader ||= Factories::SourceReaderFactory.new(@source).reader
      end

      def manifest_updater
        @manifest_updater ||= Services::ManifestUpdater.new instance
      end

      def converters_config
        @converters_config ||= Services::ConvertersConfig.get
      end

      def instance
        @instance ||= Instance.find_by id: @instance_id
      end

      def builder_file_paths
        grouped_builder_files.values.flatten.map{|h| h[:path]}
      end

      def should_remove_models
        reader.class != NewMarketplaceBuilder::SourceReaders::SyncReader
      end
    end

    class ResourceImporter
      def initialize(instance, manifest_updater, converters_config, pattern, builder_files, should_remove = true)
        @instance = instance
        @manifest_updater = manifest_updater
        @converters_config = converters_config
        @pattern = pattern
        @builder_files = builder_files
        @should_remove = should_remove
      end

      def call
        remove_unused_records! if @should_remove && should_remove_records
        converter_instance.import builder_files_with_changed_md5
      end

      def remove_unused_records!
        used_primary_keys = []

        parsed_builder_files.each do |builder_file|
          used_primary_keys.push builder_file[converter_primary_key]
        end

        converter_instance.scope.where.not(converter_primary_key => used_primary_keys).destroy_all
      end

      def builder_files_with_changed_md5
        files_with_changed_md5 = []

        @builder_files.select.with_index do |builder_file, index|
          builder_file_md5 = Digest::MD5.hexdigest builder_file[:content]
          current_md5 = @manifest_updater.get_md5(builder_file[:path])

          @manifest_updater.set_md5(builder_file[:path], builder_file_md5)
          files_with_changed_md5.push parsed_builder_files[index] if current_md5 != builder_file_md5
        end

        files_with_changed_md5
      end

      def parsed_builder_files
        @parsed_builder_files ||= @builder_files.map do |builder_file|
          parser.new(builder_file[:content], builder_file[:path]).parse
        end
      end

      def should_remove_records
        [Converters::TranslationConverter].exclude? converter
      end

      def converter_primary_key
        converter.primary_key_value.to_s
      end

      def converter
        @converter ||= @converters_config[@pattern][:converter]
      end

      def parser
        @parser ||= @converters_config[@pattern][:parser]
      end

      def converter_instance
        @converter_instance ||= converter.new(@instance)
      end
    end
  end
end
