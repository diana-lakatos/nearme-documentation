# frozen_string_literal: true
module Graph
  module Resolvers
    class Transactables < ActiveRecordCollection
      def call(_, arguments, ctx)
        @variables = ctx.query.variables
        @arguments = arguments
        decorate(resolve_by(arguments))
      end

      def self.decorate(transactable)
        ::TransactableDrop.new(transactable.decorate)
      end

      def decorate(relation)
        WillPaginate::Collection.create(@arguments[:paginate][:page], @arguments[:paginate][:per_page], relation.count) do |pager|
          pager.replace(relation.map { |transactable| self.class.decorate(transactable) })
        end
      end

      def resolve_by_ids(relation, ids)
        relation.where(id: ids)
      end

      def resolve_by_creator_id(relation, creator_id)
        relation.where(creator_id: creator_id)
      end

      def resolve_by_listing_type_id(listing_type_id)
        relation.for_transactable_type_id(listing_type_id)
      end

      def resolve_by_filters(relation, filters)
        scopes = filters.map(&:downcase)
        scopes.reduce(relation) do |scoped_relation, scope_name|
          scoped_relation.public_send(scope_name)
        end
      end

      private

      def main_scope
        all = ::Transactable.all.order(created_at: :desc)
        if @variables['follower_id']
          all.merge(ActivityFeedSubscription.with_user_id_as_follower(@variables['follower_id'], ::Transactable))
        else
          all
        end
      end

      class CustomAttributePhotos < Resolvers::CustomAttributePhotosBase
        private

        def custom_images_ids(custom_images)
          transactable = object.source
          images = custom_images.where(owner: transactable)
          customization_images = custom_images.where(
            owner_type: ::Customization.to_s,
            owner_id: transactable.customizations.pluck(:id)
          )
          images.pluck(:id) + customization_images.pluck(:id)
        end
      end
    end
  end
end
