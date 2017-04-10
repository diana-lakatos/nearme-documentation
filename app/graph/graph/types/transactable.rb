# frozen_string_literal: true
module Graph
  module Types
    Transactable = GraphQL::ObjectType.define do
      name 'Transactable'
      description 'PPPP'

      global_id_field :id

      field :id, !types.Int
      field :is_followed, !types.Boolean do
         argument :follower_id, types.ID
         resolve ->(obj, arg, _) { arg[:follower_id] ? obj.is_followed : false }
      end

      field :location_id, !types.ID
      field :latitude, types.String
      field :longitude, types.String
      field :name, !types.String
      field :description, !types.String
      field :show_path, !types.String
      field :photo_url, !types.String
      field :cover_photo_url, !types.String
      field :cover_photo_thumbnail_url, !types.String
      field :summary, !types.String
      field :url, !types.String
      field :creator, !Types::User do
        resolve ->(obj, _args, _ctx) { UserDrop.new(obj.creator) }
      end
      field :custom_attribute_photos,
            !types[Types::Image],
            'Fetch images for photo custom attribute by name,
             ex: cover_images: custom_attribute_photo(name: "cover_image")
             by default they are ordered by DATE' do
        argument :name, !types.String
        argument :order, Types::CustomImageOrderEnum
        argument :order_direction, Types::OrderDirectionEnum
        resolve Graph::Resolvers::Transactables::CustomAttributePhotos.new
      end
    end

    TransactableFilterEnum = GraphQL::EnumType.define do
      name 'TransactableFilter'
      description 'Available filters'
      value('ACTIVE', 'Active transactables')
      value('FEATURED', 'Featured transactables')
    end
  end
end
