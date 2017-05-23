module MarketplaceBuilder
  module ExporterTests
    class ShouldExportGraphQueries < Basic
      def initialize(instance)
        @instance = instance
      end

      def seed!
        GraphQuery.create!(instance_id: @instance.id, name: 'get_users', query_string: 'query get_user($slug: String!) {}')
      end

      def execute!
        liquid_content = read_exported_file('graph_queries/get_users.graphql', :liquid)
        assert_equal liquid_content.body, 'query get_user($slug: String!) {}'
      end
    end
  end
end
