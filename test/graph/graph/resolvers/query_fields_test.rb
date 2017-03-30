# frozen_string_literal: true
require 'test_helper_lite'
require 'graphql'
require './app/graph/graph/resolvers/query_fields'

module Graph
  module Resolvers
    class QueryFieldsTest < ActiveSupport::TestCase
      test 'to_h' do
        SomeQueryType = GraphQL::ObjectType.define do
          name 'Query'
          field :post do
            type types.String
            resolve ->(obj, args, ctx) { 'foo' }
          end
        end
        SomeSchema = GraphQL::Schema.define { query SomeQueryType }
        query = GraphQL::Query.new(SomeSchema, '{post}')

        result = Graph::Resolvers::QueryFields.new(query.document.children.first).to_h

        assert_equal(
          {:simple=>["post"], :nested=>{}},
          result
        )
      end
    end
  end
end
