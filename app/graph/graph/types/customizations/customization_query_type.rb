# frozen_string_literal: true
module Graph
  module Types
    module Customizations
      CustomizationQueryType = GraphQL::ObjectType.define do
        field :customizations do
          type !types[Types::Customizations::Customization]

          argument :id, types[types.ID]
          argument :user_id, types.ID
          argument :name, types.String
          resolve Resolvers::Customizations.new
        end

        field :customization do
          type !Types::Customizations::Customization

          argument :id, types.ID
          argument :name, types.String
          resolve Resolvers::Customization.new
        end
      end
    end
  end
end
