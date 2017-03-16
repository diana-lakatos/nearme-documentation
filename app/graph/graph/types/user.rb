# frozen_string_literal: true
module Graph
  module Types
    User = GraphQL::ObjectType.define do
      name 'User'
      description 'A user'

      global_id_field :id

      field :id, !types.ID
      field :is_followed, !types.Boolean do
        argument :follower_id, types.ID
        resolve -> (obj, arg, _) { arg[:follower_id] ? obj.is_followed : false }
      end

      field :name, !types.String
      field :email, !types.String
      field :slug, !types.String
      field :custom_attribute,
            !types.String,
            'Fetch any custom attribute by name, ex: hair_color: custom_attribute(name: "hair_color")' do
        argument :name, !types.String
        resolve ->(obj, arg, _ctx) { obj.properties[arg[:name]] }
      end

      field :profile, Types::Profile do
        argument :profile_type, !types.String
        resolve -> (obj, arg, _ctx) { obj.source.user_profiles.find_by(profile_type: arg[:name]) }
      end

      field :custom_attribute_photos,
            !types[Types::Image],
            'Fetch images for photo custom attribute by name,
             ex: cover_images: custom_attribute_photo(name: "cover_image")
             by default they are ordered by DATE' do
        argument :name, !types.String
        argument :order, Types::CustomImageOrderEnum
        argument :order_direction, Types::OrderDirectionEnum
        resolve Graph::Resolvers::Users::CustomAttributePhotos.new
      end

      field :profile_path, !types.String
      field :avatar_url_thumb, !types.String
      field :avatar_url_bigger, !types.String
      field :name_with_affiliation, !types.String
      field :display_location, !types.String
      field :current_address, Types::Address
      field :collaborations, types[Types::Collaboration] do
        argument :filters, types[Resolvers::Collaborations::FilterEnum]
        resolve Graph::Resolvers::Collaborations.new
      end
    end

    CustomImageOrderEnum = GraphQL::EnumType.define do
      name 'CustomImageOrder'
      description 'Available order for custom images'
      value('DATE', 'Date added image', value: :created_at)
    end

    OrderDirectionEnum = GraphQL::EnumType.define do
      name 'OrderDirection'
      description 'Order direction'
      value('DESC', 'Desc')
      value('ASC', 'Asc')
    end

    UserFilterEnum = GraphQL::EnumType.define do
      name 'UserFilter'
      description 'Available filters'
      value('FEATURED', 'Featured users')
      value('FEED_NOT_FOLLOWED_BY_USER', 'Not followed by current user')
    end
  end
end
