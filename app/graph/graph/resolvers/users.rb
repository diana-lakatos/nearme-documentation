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
          attribute_images = ::CustomImage.where(custom_attribute: custom_attribute)
          custom_images = attribute_images.where(owner: user.user_profiles) +
                          attribute_images.where(owner: user.user_profiles.map(&:customizations).flatten)
          custom_images.map(&:image)
        end
      end
    end
  end
end
