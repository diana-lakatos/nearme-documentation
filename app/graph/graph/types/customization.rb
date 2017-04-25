# frozen_string_literal: true
module Graph
  module Types
    Customization = GraphQL::ObjectType.define do
      name 'Customization'

      global_id_field :id

      field :id, !types.Int
      field :custom_attribute,
            types.String,
            'Fetch any custom attribute by name, ex: hair_color: custom_attribute(name: "hair_color")' do
        argument :name, !types.String
        resolve ->(obj, arg, _ctx) { obj.properties[arg[:name]] }
      end
      field :custom_image, Types::EsImage do
        argument :name, !types.String
        resolve ->(obj, arg, _ctx) { obj.custom_images[arg[:name]] }
      end
      field :custom_attachment, Types::File do
        argument :name, !types.String
        resolve ->(obj, arg, _ctx) { obj.custom_attachments[arg[:name]] }
      end
    end
  end
end
