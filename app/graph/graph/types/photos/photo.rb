# frozen_string_literal: true
module Graph
  module Types
    module Photos
      Photo = GraphQL::ObjectType.define do
        name 'Photo'

        field :id, types.ID
        field :image, Graph::Types::Image
        field :creator, !Graph::Types::User do
          resolve ->(obj, _arg, ctx) { Resolvers::User.new.call(nil, { id: obj.creator_id }, ctx) }
        end
      end
    end
  end
end
