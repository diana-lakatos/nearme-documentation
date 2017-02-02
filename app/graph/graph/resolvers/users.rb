# frozen_string_literal: true
module Graph
  module Resolvers
    class Users
      def call(_, arguments, ctx)
        @ctx = ctx
        decorate(resolve_by(arguments))
      end

      def resolve_by(arguments)
        arguments.keys.reduce(::User.all) do |relation, argument_key|
          public_send("resolve_by_#{argument_key}", relation, arguments[argument_key])
        end
      end

      def decorate(relation)
        relation.map { |user| UserDrop.new(user) }
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

      class CustomAttributePhotos
        def call(obj, arg, _ctx)
          user = obj.source
          custom_attribute = ::CustomAttributes::CustomAttribute.find_by(name: arg[:name])
          custom_images = ::CustomImage.where(id: custom_images_ids(custom_attribute, user))
                                       .order(order(arg) => order_direction(arg))
          custom_images.map(&:image)
        end

        private

        def custom_images_ids(custom_attribute, user)
          attribute_images = ::CustomImage.where(custom_attribute: custom_attribute)
          profile_images = attribute_images.where(owner: user.user_profiles)
          customization_images = attribute_images.where(
            owner_type: ::Customization.to_s,
            owner_id: user.user_profiles.map{ |up| up.customizations.pluck(:id) }.flatten
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
