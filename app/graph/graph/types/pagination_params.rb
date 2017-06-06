# frozen_string_literal: true
module Graph
  module Types
    PaginationParams = GraphQL::InputObjectType.define do
      name('PaginationParams')
      argument :page, types.Int, default_value: 1
      argument :per_page, types.Int, default_value: 10
    end
  end
end
