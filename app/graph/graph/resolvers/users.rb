# frozen_string_literal: true
module Graph
  module Resolvers
    class Users
      def call(_, arguments, ctx)
        @ctx = ctx
        @arguments = arguments

        resolve_by
      end

      def resolve_by
        fetch(query_for_arguments)
      end

      def resolve_by_take(query, number)
        query.add size: number
      end

      def resolve_by_filters(query, filters)
        query.add query: { term: map_filters_into_term(filters) }
      end

      def resolve_by_ids(query, ids)
        query.add query: { ids: { values: ids } }
      end

      private

      ARGUMENTS_RESOLVE_ORDER = [:filter, :take, :ids].freeze
      ARGUMENTS_RESOLVERS_MAP = {
        filters: :resolve_by_filters,
        take: :resolve_by_take,
        ids: :resolve_by_ids
      }.freeze
      FILTER_TERMS_MAP = {
        featured: { featured: true }
      }.freeze

      def query_for_arguments
        argument_keys.reduce(Elastic::QueryBuilder::Franco.new) do |query, argument_key|
          method = ARGUMENTS_RESOLVERS_MAP[argument_key.to_sym]
          value = @arguments[argument_key]
          public_send(method, query, value)
        end
      end

      def fetch(query)
        UserEs.new(query: query, ctx: @ctx).fetch
      end

      def map_filters_into_term(filters)
        filters = filters.map(&:downcase).map(&:to_sym)
        FILTER_TERMS_MAP.slice(*filters)
                        .values
                        .reduce({}, :merge)
      end

      def argument_keys
        @arguments.keys.sort_by { |key| ARGUMENTS_RESOLVE_ORDER.index(key) }
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
