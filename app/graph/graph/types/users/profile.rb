# frozen_string_literal: true
module Graph
  module Types
    module Users
      Profile = GraphQL::ObjectType.define do
        name 'Profile'
        description 'A profile'

        global_id_field :id

        field :id, !types.Int
        field :enabled, !types.Boolean
        field :profile_type, !types.String
        field :custom_attribute,
              types.String,
              'Fetch any custom attribute by name, ex: hair_color: custom_attribute(name: "hair_color")' do
          argument :name, !types.String
          resolve ->(obj, arg, _ctx) { obj.properties[arg[:name]] }
        end

        field :custom_attribute_array, types[types.String] do
          argument :name, !types.String
          resolve ->(obj, arg, _ctx) { obj.properties[arg[:name]] }
        end
        field :custom_image, Types::EsImage do
          argument :name, !types.String
          resolve ->(obj, arg, _ctx) { obj.custom_images[arg[:name]] }
        end
        field :customizations, !types[Types::Customization] do
          argument :name, !types.String
          resolve ->(obj, arg, _ctx) { obj.customizations.fetch(arg[:name], []) }
        end
      end
    end
  end
end
