# frozen_string_literal: true
module Graph
  module Types
    CustomAttributeInterface = GraphQL::InterfaceType.define do
      name 'CustomAttributeInterface'

      global_id_field :id
      field :id, !types.ID

      field :property,
            types.String,
            'Fetch any custom attribute by name, ex: hair_color: property(name: "hair_color")' do
        argument :name, !types.String
        resolve ->(obj, args, _ctx) { obj.properties[args[:name]] }
      end

      field :property_array, types[types.String] do
        argument :name, !types.String
        resolve ->(obj, args, _ctx) { obj.properties[args[:name]] }
      end

      field :custom_image, Types::EsImage do
        argument :name, !types.String
        resolve ->(obj, args, _ctx) { obj.custom_images.find { |ci| ci.name == args[:name] } }
      end

      field :custom_attachment, Types::PrivateFile do
        argument :name, !types.String
        resolve ->(obj, arg, _ctx) { obj.custom_attachments[arg[:name]] }
      end
    end
  end
end
