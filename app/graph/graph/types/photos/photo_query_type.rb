# frozen_string_literal: true
module Graph
  module Types
    module Photos
      PhotoQueryType = GraphQL::ObjectType.define do
        field :photos do
          type !Graph::Types::Collection.build(Types::Photos::Photo)
          argument :since, types.Int, 'A Unix timestamp'
          argument :paginate, Types::PaginationParams, default_value: { page: 1, per_page: 10 }

          resolve Graph::Resolvers::Photos.new
        end
      end
    end
  end
end
