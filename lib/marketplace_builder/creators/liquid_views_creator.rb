# frozen_string_literal: true
module MarketplaceBuilder
  module Creators
    class LiquidViewsCreator < TemplatesCreator
      def cleanup!
        liquid_views = get_templates

        unused_liquid_views = if liquid_views.empty?
                                @instance.instance_views.liquid_views.all
                              else
                                @instance.instance_views.liquid_views.where('path NOT IN (?)', liquid_views.map(&:liquid_path))
                              end

        unused_liquid_views.each { |lv| logger.debug "Removing unused liquid view: #{lv.path}" }
        unused_liquid_views.destroy_all
      end

      private

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

      rescue
      end
    end
  end
end
