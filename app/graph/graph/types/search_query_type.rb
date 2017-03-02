# frozen_string_literal: true
module Graph
  module Types
    SearchQueryType = GraphQL::ObjectType.define do
      field :search_transactables do
        type !Types::Search::Searcher
        argument :kind, !types.String
        argument :params, Types::Search::Params
        resolve Resolvers::Searcher.new
      end
    end
  end
end
