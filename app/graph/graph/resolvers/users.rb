# frozen_string_literal: true
module Graph
  module Resolvers
    class Users
      def call(_, arguments, ctx)
        @ctx = ctx
        @variables = ctx.query.variables
        @arguments = arguments

        resolve_by
      end

      def resolve_by
        return all if argument_keys.empty?
        argument_keys.reduce([]) do |collection, argument_key|
          method = ARGUMENTS_RESOLVERS_MAP[argument_key]
          value = @arguments[argument_key]
          public_send(method, collection, value)
        end
      end

      def resolve_by_take(collection, number)
        collection.take(number)
      end

      def resolve_by_filters(_collection, filters)
        query = { term: map_filters_into_term(filters) }
        fetch(query)
      end

      def all
        query = { match_all: { boost: 1.0 } }
        fetch(query)
      end

      private

      ARGUMENTS_RESOLVE_ORDER = [:filter, :take].freeze
      ARGUMENTS_RESOLVERS_MAP = {
        filters: :resolve_by_filters,
        take: :resolve_by_take
      }
      FILTER_TERMS_MAP = {
        featured: { featured: true }
      }

      def fetch(query)
        UserEs.new(query: query, ctx: @ctx).fetch
      end

      def map_filters_into_term
        filters = filters.map(&:downcase).map(&:to_sym)
        FILTER_TERMS_MAP.slice(*filters)
                        .values
                        .reduce({}, :merge)
      end

      def argument_keys
        @arguments.keys.sort_by{ |key| ARGUMENTS_RESOLVE_ORDER.index(key) }
      end

      class CustomAttributePhotos < Resolvers::CustomAttributePhotosBase
        private

        def custom_images_ids(custom_images)
          user = Resolvers::User.find_model(@object)
          profile_images = custom_images.where(owner: user.user_profiles)
          customization_images = custom_images.where(
            owner_type: ::Customization.to_s,
            owner_id: user.user_profiles.map { |user_profile| user_profile.customizations.map(&:id) }.flatten
          )
          profile_images.pluck(:id) + customization_images.pluck(:id)
        end
      end
    end
  end
end
