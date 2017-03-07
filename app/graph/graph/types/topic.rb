# frozen_string_literal: true
module Graph
  module Types
    Topic = GraphQL::ObjectType.define do
      name 'Topic'
      description 'A topic'

      global_id_field :id

      field :id, !types.ID
      field :is_followed, !types.Boolean do
        argument :follower_id, types.ID
        resolve ->(obj, arg, _) { arg[:follower_id] ? obj.is_followed : false }
      end

      field :name, !types.String
      field :show_url, !types.String
      field :background_style, !types.String
      field :background_style_big, !types.String
      field :listing_image_url, !types.String
    end

    TopicFilterEnum = GraphQL::EnumType.define do
      name 'TopicFilter'
      description 'Available filters'
      value('FEATURED', 'Featured users')
    end
  end
end
