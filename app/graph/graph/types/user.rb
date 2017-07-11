# frozen_string_literal: true
# rubocop:disable Metrics/BlockLength
module Graph
  module Types
    User = GraphQL::ObjectType.define do
      name 'User'
      description 'A user'

      global_id_field :id

      field :id, !types.ID
      field :is_followed, !types.Boolean do
        argument :follower_id, types.ID
        resolve ->(user, arg, _) { ::ActivityFeedSubscription.followed_by_user?(user.id, ::User, arg['follower_id']) }
      end
      field :name, types.String
      field :first_name, types.String
      field :last_name, types.String
      field :email, !types.String
      field :slug, !types.String
      field :seller_average_rating, !types.Int

      field :property,
            types.String,
            'Fetch any custom attribute by name, ex: hair_color: property(name: "hair_color")' do
        argument :name, !types.String
        deprecation_reason 'Fetch custom_attribute directly from profile'
        resolve ->(obj, arg, _ctx) { Graph::Resolvers::User.find_model(obj).properties[arg[:name]] }
      end

      field :profile, Types::Users::Profile do
        argument :profile_type, !types.String
        resolve ->(obj, args, _ctx) { obj.user_profiles.find { |up| up.profile_type == args[:profile_type] } }
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

      field :profile_path, !types.String, deprecation_reason: 'Use generate_url filter' do
        resolve ->(obj, _arg, _ctx) { format('/users/%s', obj.slug) }
      end

      field :avatar_url_thumb, types.String, deprecation_reason: 'Use avatar{}' do
        resolve ->(obj, _arg, _ctx) { obj.avatar&.thumb&.url }
      end
      field :avatar_url_bigger, types.String, deprecation_reason: 'Use avatar{}' do
        resolve ->(obj, _arg, _ctx) { obj.avatar&.bigger&.url }
      end
      field :avatar_url_big, types.String, deprecation_reason: 'Use avatar{}' do
        resolve ->(obj, _arg, _ctx) { obj.avatar&.big&.url }
      end
      field :avatar, Types::EsImage
      field :name_with_affiliation, !types.String do
        resolve ->(obj, _arg, _ctx) { Resolvers::User.find_model(obj).to_liquid.name_with_affiliation }
      end
      field :display_location, types.String do
        resolve ->(obj, _arg, _ctx) { Resolvers::User.find_model(obj).to_liquid.display_location }
      end
      field :current_address, Types::Address #, deprecation_reason: 'Use custom-address'

      field :collaborations, types[Types::Collaboration] do
        argument :filters, types[Resolvers::Collaborations::FilterEnum]
        resolve Graph::Resolvers::Collaborations.new
      end

      field :group_collaborations, types[Types::GroupCollaboration] do
        argument :filters, types[Resolvers::GroupCollaborations::FilterEnum]
        resolve Graph::Resolvers::GroupCollaborations.new
      end

      field :threads do
        type !types[Graph::Types::Thread]
        argument :take, types.Int

        resolve Graph::Resolvers::MessageThreads.new
      end

      field :thread do
        type Types::Thread
        argument :id, types.ID

        resolve Resolvers::MessageThread.new
      end

      field :profile_property,
            types.String,
            'Fetch any property of given kind by name, ex: bio: profile_property(profile_type: "buyer", name: "bio")' do
              argument :name, !types.String
              argument :profile_type, !types.String
              resolve(
                lambda do |obj, arg, _ctx|
                  Resolvers::User.find_model(obj)
                                 .user_profiles
                                 .joins(:instance_profile_type)
                                 .find_by(instance_profile_types: { parameterized_name: arg[:profile_type] })
                                 .properties[arg[:name]]
                end
              )
            end

      field :transactables, types[Types::Transactables::Transactable] do
        resolve ->(obj, _arg, _) { ::Transactable.where(creator_id: obj.id) }
      end

      field :reviews, !types[Types::Review], 'Review about a user as seller' do
        resolve Resolvers::Reviews.new
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
    end
  end
end
