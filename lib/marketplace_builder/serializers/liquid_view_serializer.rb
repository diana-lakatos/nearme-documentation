module MarketplaceBuilder
  module Serializers
    class LiquidViewSerializer < BaseSerializer
      resource_name -> (p) { "liquid_views/#{p.path}" }

      properties :partial

      property :content

      def content(liquid_view)
        liquid_view.body
      end

      def scope
        InstanceView.where(view_type: 'view', instance_id: @model.id).all
      end
    end
  end
end
