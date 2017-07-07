# frozen_string_literal: true
module Graph
  module Types
    module Customizations
      Customization = GraphQL::ObjectType.define do
        name 'Customization'

        global_id_field :id

        field :id, !types.ID
        field :created_at, types.String
        field :customizable, Types::Customizations::Customizable
        field :user, !Types::User do
          resolve ->(obj, _arg, ctx) { Resolvers::User.new.call(nil, { id: obj.user_id }, ctx) }
        end
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
        field :custom_attachment, Types::PrivateFile do
          argument :name, !types.String
          resolve lambda { |obj, arg, _ctx|
            obj.custom_attachments.includes(:custom_attribute)
               .where(custom_attributes: { name: arg[:name] }).first
          }
        end
        field :custom_attribute_array, types[types.String] do
          argument :name, !types.String
          resolve ->(obj, arg, _ctx) { obj.properties[arg[:name]] }
        end
      end
    end
  end
end