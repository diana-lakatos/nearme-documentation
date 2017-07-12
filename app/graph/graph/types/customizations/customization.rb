# frozen_string_literal: true
module Graph
  module Types
    module Customizations
      Customization = GraphQL::ObjectType.define do
        interfaces [Graph::Types::CustomAttributeInterface]

        name 'Customization'

        global_id_field :id

        field :id, !types.ID
        field :created_at, types.String
        field :customizable, Types::Customizations::Customizable
        field :human_name, types.String
        field :name, types.String
        field :user, !Types::User do
          resolve ->(obj, _arg, ctx) { Resolvers::User.new.call(nil, { id: obj.user_id }, ctx) }
        end
      end
    end
  end
end
