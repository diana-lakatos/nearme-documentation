module MarketplaceBuilder
  module ExporterTests
    class Basic < ActiveSupport::TestCase
      def initialize(instance)
        @instance = instance
      end

      def seed!
      end

      def execute!
      end

      protected

      def read_exported_file(path, reader = :yml)
        if reader == :yml
          YAML.load(File.read("#{MarketplaceBuilder::ExporterTest::EXPORT_DESTINATION_PATH}/ExportTestInstance/#{path}"))
        elsif reader == :liquid
          MarketplaceBuilder::Creators::TemplatesCreator.load_file_with_yaml_front_matter("#{MarketplaceBuilder::ExporterTest::EXPORT_DESTINATION_PATH}/ExportTestInstance/#{path}", 'test')
        else
          raise 'Not implemented reader'
        end
      end
    end
  end
end
