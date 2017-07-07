# frozen_string_literal: true
module Graph
  module Types
    module Transactables
      Transactable = GraphQL::ObjectType.define do
        name 'Transactable'

        global_id_field :id

        field :id, !types.Int
        field :created_at, types.String
        field :updated_at, types.String
        field :cover_photo_thumbnail_url, types.String, deprecation_reason: 'Use cover_photo { url(version: "thumb") }'
        field :cover_photo_url, types.String, deprecation_reason: 'Use cover_photo{ url }'
        field :cover_photo, Types::Image do
          resolve ->(obj, _arg, _ctx) { obj.source.cover_photo.image }
        end
        field :creator_id, types.ID
        field :creator, !Types::User do
          resolve ->(obj, _arg, ctx) { Resolvers::User.new.call(nil, { id: obj.creator_id }, ctx) }
        end
        field :currency, !types.String
        field :description, types.String
        field :is_followed, !types.Boolean do
          argument :follower_id, types.ID
          resolve ->(obj, arg, _) { arg[:follower_id] ? obj.is_followed : false }
        end
        field :latitude, types.String
        field :location_id, types.ID
        field :formatted_address, types.String
        field :longitude, types.String
        field :name, types.String
        field :photo_url, types.String
        field :show_path, !types.String, deprecation_reason: 'Use generate_url filter'
        field :slug, !types.String
        field :state, types.String
        field :summary, types.String
        field :time_zone, types.String
        field :url, types.String, deprecation_reason: 'Use generate_url filter'
        field :time_based_booking, Types::Transactables::TimeBasedBooking
        field :orders, !types[Types::Orders::Order] do
          resolve ->(obj, _args, _ctx) { obj.source.orders }
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

        field :property,
              types.String,
              'Fetch any custom attribute by name, ex: hair_color: property(name: "hair_color")' do
          argument :name, !types.String
          resolve ->(obj, arg, _ctx) { obj.properties[arg[:name]] }
        end

        field :property_array, !types[types.String] do
          argument :name, !types.String
          resolve ->(obj, arg, _ctx) { obj.properties[arg[:name]] }
        end
        field :comments, Graph::Types::Collection.build(Types::ActivityFeed::Comment) do
          argument :paginate, Types::PaginationParams, default_value: { page: 1, per_page: 10 }
          resolve ->(obj, arg, ctx) {
            comment_ids = ::ActivityFeedEvent.comments_for_transactable(obj.id).pluck(:event_source_id)
            Graph::Resolvers::Comments.new(
              ::Comment.where(id: comment_ids)
            ).call(obj, arg, ctx)
          }
        end
        field :followers, Graph::Types::Collection.build(Types::User) do
          resolve ->(obj, _arg, ctx) {
            Graph::Resolvers::Users.new.call(nil, { ids: obj.source.activity_feed_subscriptions.pluck(:follower_id) }, ctx)
          }
        end
        field :week_availability, !types[Types::Transactables::DayAvailability] do
          argument :step, !types.Int
          resolve -> (obj, args, ctx) { AvailabilityRule::WeekAvailability.new(obj.action_type, args[:step]).as_json }
        end
        field :day_availability, !types[Types::Transactables::Availability] do
          argument :date, !types.String
          argument :step, !types.Int
          resolve -> (obj, args, ctx) { AvailabilityRule::HourlyListingStatus.new(obj.action_type, Date.parse(args[:date]), args[:step]).day_availability }
        end

        field :customizations, !types[Types::Customizations::Customization],
              'Fetch any customization by name or id, ex: hair_color: customization(name: "hair_color")' do
          argument :id, types.ID
          argument :custom_model_type_name, types.String
          resolve ->(obj, arg, ctx) { Resolvers::Customizations.new.call(obj.source.object, arg, ctx) }
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
end
