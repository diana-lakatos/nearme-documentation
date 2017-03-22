# frozen_string_literal: true
module Graph
  module Resolvers
    class Users
      def self.decorate(user)
        UserDrop.new(user)
      end

      def call(_, arguments, ctx)
        @ctx = ctx
        @variables = ctx.query.variables
        decorate(resolve_by(arguments))
      end

      def resolve_by(arguments)
        arguments.keys.reduce(main_scope) do |relation, argument_key|
          public_send("resolve_by_#{argument_key}", relation, arguments[argument_key])
        end
      end

      def decorate(relation)
        relation.map { |user| self.class.decorate(user) }
      end

      def resolve_by_filters(relation, filters)
        scopes = filters.map(&:downcase)
        scopes.reduce(relation) do |scoped_relation, scope_name|
          if scope_name == 'feed_not_followed_by_user'
            scoped_relation.public_send(scope_name, current_user)
          else
            scoped_relation.public_send(scope_name)
          end
        end
      end

      def resolve_by_take(relation, number)
        relation.take(number)
      end

      private

      def current_user
        @ctx[:current_user].source
      end

      def main_scope
        return ::User.all unless @variables['follower_id']
        ::User.all
              .merge(ActivityFeedSubscription.with_user_id_as_follower(@variables['follower_id'], ::User))
      end

      class CustomAttributePhotos
        def call(obj, arg, _ctx)
          user = obj.source
          custom_attributes = ::CustomAttributes::CustomAttribute.where(name: arg[:name])
          custom_images = ::CustomImage.where(id: custom_images_ids(custom_attributes, user))
                                       .order(order(arg) => order_direction(arg))
          custom_images.map(&:image)
        end

        private

        def custom_images_ids(custom_attributes, user)
          attribute_images = ::CustomImage.where(custom_attribute: custom_attributes)
          profile_images = attribute_images.where(owner: user.user_profiles)
          customization_images = attribute_images.where(
            owner_type: ::Customization.to_s,
            owner_id: user.user_profiles.map { |up| up.customizations.pluck(:id) }.flatten
          )
          profile_images.pluck(:id) + customization_images.pluck(:id)
        end

        def order(arg)
          arg[:order] || default_order
        end

        def order_direction(arg)
          arg[:order_direction] || default_order_direction
        end

        def default_order_direction
          Graph::Types::OrderDirectionEnum.values['ASC'].value
        end

        def default_order
          Graph::Types::CustomImageOrderEnum.values['DATE'].value
        end
      end
    end
  end
end
