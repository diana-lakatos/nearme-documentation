# frozen_string_literal: true
module MarketplaceBuilder
  module Creators
    class LiquidViewsCreator < TemplatesCreator
      private

      def cleanup!
        @instance.instance_views.liquid_views.destroy_all
      end

      def object_name
        'LiquidView'
      end

      def create!(template)
        iv = InstanceView.where(
          instance_id: @instance.id,
          path: template.liquid_path
        ).first_or_initialize
        iv.update!(transactable_types: TransactableType.all,
                   body: template.body,
                   format: 'html',
                   handler: 'liquid',
                   partial: template.partial,
                   view_type: 'view',
                   locales: Locale.all)
      end
    end
  end
end
