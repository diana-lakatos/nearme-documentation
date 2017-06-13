require_relative 'basic'

module MarketplaceBuilder
  module ExporterTests
    class ShouldExportReservationTypes < Basic
      def initialize(instance)
        @instance = instance
      end

      def execute!
        @instance.reservation_types.each do |rt|
          yaml_content = read_exported_file("reservation_types/#{rt.name.to_s.parameterize.underscore}.yml")
          assert_equal yaml_content['name'], rt.name
        end
      end
    end
  end
end
