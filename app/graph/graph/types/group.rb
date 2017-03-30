# frozen_string_literal: true
module Graph
  module Types
    Group = GraphQL::ObjectType.define do
      name 'Group'
      global_id_field :id

      field :id, !types.ID
      field :name, !types.String
      field :show_path, !types.String do
        resolve ->(obj, _arg, _ctx) { obj.to_liquid.show_path }
      end
      field :cover_photo, Types::Image do
        resolve ->(obj, _arg, _ctx) { obj.cover_photo&.image }
      end
      field :creator, !Types::User do
        resolve ->(obj, _arg, ctx) { Resolvers::User.new.call(nil, {id: obj.creator_id }, ctx) }
      end
    end
  end
end
