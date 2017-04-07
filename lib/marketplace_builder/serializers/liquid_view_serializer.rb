# frozen_string_literal: true
module MarketplaceBuilder
  module Serializers
    class LiquidViewSerializer < BaseSerializer
      property :content

      def content(liquid_view)
        liquid_view.body
      end

      def scope
        InstanceView.where(view_type: 'view', instance_id: @model.id).all
      end

      def resource_name(instance_view)
        path = if instance_view.partial
                 file_name = instance_view.path.split('/').last
                 instance_view.path.gsub(/#{file_name}$/, "_#{file_name}")
               else
                 instance_view.path
               end
        "liquid_views/#{path}"
      end
    end
  end
end
