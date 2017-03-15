# frozen_string_literal: true
module Graph
  module Types
    Profile = GraphQL::ObjectType.define do
      name 'Profile'
      description 'A profile'

      global_id_field :id

      field :id, !types.ID
      field :profile_type, !types.String
      field :custom_attribute,
            !types.String,
            'Fetch any custom attribute by name, ex: hair_color: custom_attribute(name: "hair_color")' do
        argument :name, !types.String
        resolve -> (obj, arg, _ctx) { obj.properties[arg[:name]] }
      end
    end
  end
end
