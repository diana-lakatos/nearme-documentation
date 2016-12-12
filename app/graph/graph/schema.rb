# frozen_string_literal: true
module Graph
  Schema = GraphQL::Schema.define do
    query Types::RootQuery
  end
end
