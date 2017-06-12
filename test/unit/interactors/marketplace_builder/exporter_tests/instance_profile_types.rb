require_relative 'basic'

module MarketplaceBuilder
  module ExporterTests
    class ShouldExportInstanceProfileTypes < Basic
      def initialize(instance)
        @instance = instance
      end

      def execute!
        yaml_content = read_exported_file('instance_profile_types/default.yml')
        assert_equal yaml_content['name'], 'Default'
      end
    end
  end
end
