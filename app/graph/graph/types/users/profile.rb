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
        field :custom_attribute,
              types.String,
              'Fetch any custom attribute by name, ex: hair_color: custom_attribute(name: "hair_color")' do
          argument :name, !types.String
          resolve ->(obj, arg, _ctx) { obj.properties[arg[:name]] }
        end
        field :availability_template, Graph::Types::AvailabilityTemplate

        field :customizations, !types[Graph::Types::Customization] do
          argument :name, !types.String
          resolve ->(obj, args, _ctx) { obj.customizations.select { |c| c.name == args[:name] } }
        end
      end
    end
  end
end
