module MarketplaceBuilder
  module BuilderTests
    class ShouldImportGraphQueries < ActiveSupport::TestCase
      def initialize(instance)
        @instance = instance
      end

      def execute!
        graph_query = @instance.graph_queries.last
        assert_equal graph_query.name, 'get_user'
        assert graph_query.query_string.include?('query get_user($slug: String!)')
      end
    end
  end
end
