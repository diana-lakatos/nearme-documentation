# frozen_string_literal: true
module Graph
  module Resolvers
    class CustomAttributePhotosBase
      attr_reader :object

      def call(obj, arg, _ctx)
        @object = obj
        custom_images = find_custom_images(arg[:name])
                        .order(order(arg) => order_direction(arg))
        custom_images.map(&:image)
      end

      private

      def find_custom_images(name)
        relation = ::CustomImage.joins(:custom_attribute)
                                .where(custom_attributes: { name: name })
        ::CustomImage.where(id: custom_images_ids(relation))
      end

      def custom_images_ids(_custom_images)
        raise NotImplementedError
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
