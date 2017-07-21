# frozen_string_literal: true
module Graph
  module Types
    module Users
      Profile = GraphQL::ObjectType.define do
        interfaces [Graph::Types::CustomAttributeInterface]
        name 'Profile'
        description 'A profile'

        field :enabled, !types.Boolean
        field :profile_type, !types.String
        field :onboarded_at, types.String
        field :availability_template, Graph::Types::AvailabilityTemplate
        field :customizations, types[Graph::Types::Customizations::Customization] do
          argument :name, !types.String
          argument :user_id, types.ID, prepare: Graph::Arguments::PrepareInteger.new
          resolve lambda { |obj, args, ctx|
            Graph::Resolvers::Elastic::HashResolver.new.call(obj.customizations, args, ctx)
          }
        end
        field :category_list, types[Graph::Types::Category] do
          argument :name_of_root, types.String

          resolve lambda { |obj, arg, _ctx|
            obj
              .category_list
              .select { |c| arg[:name_of_root].blank? || c.name_of_root == arg[:name_of_root] }
              .sort_by(&:permalink)
          }
        end
      end
    end
  end
end
