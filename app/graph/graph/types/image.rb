# frozen_string_literal: true
module Graph
  module Types
    Image = GraphQL::ObjectType.define do
      name 'Image'
      description 'Generic image'

      field :url,
            !types.String,
            'image url, ex: thumb: url(version: "thumb")' do
        argument :version, types.String
        resolve ->(obj, arg, _ctx) { arg[:version].present? ? obj.url(arg[:version]) : obj.url }
      end

      field :image_original_width,
            !types.Int,
            'image original width' do
        resolve ->(obj, _arg, _ctx) { obj.model.image_original_width }
      end

      field :image_original_height,
            !types.Int,
            'image original height' do
        resolve ->(obj, _arg, _ctx) { obj.model.image_original_height }
      end
    end
  end
end
