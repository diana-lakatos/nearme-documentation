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
          YAML.load(exported_file(path))
        elsif reader == :liquid
          MarketplaceBuilder::Creators::TemplatesCreator.load_file_with_yaml_front_matter(full_path(path), 'test')
        else
          raise 'Not implemented reader'
        end
      end

      def full_path(path)
        "#{MarketplaceBuilder::ExporterTest::EXPORT_DESTINATION_PATH}/exporttestinstance/#{path}"
      end

      def exported_file(path)
        File.read(full_path(path))
      end
    end
  end
end
