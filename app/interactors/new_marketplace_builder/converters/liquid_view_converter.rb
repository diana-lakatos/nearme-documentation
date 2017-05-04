# frozen_string_literal: true
module NewMarketplaceBuilder
  module Converters
    class LiquidViewConverter < BaseConverter
      primary_key :path
      properties :body, :path, :partial

      def scope
        InstanceView.where(view_type: 'view', instance_id: @model.id)
      end

      def resource_name(liquid)
        return liquid.path unless liquid.partial
        "#{File.dirname(liquid.path)}/_#{File.basename(liquid.path)}"
      end

      def default_values(_liquid)
        {
          transactable_types: TransactableType.all,
          format: 'html',
          handler: 'liquid',
          locales: Locale.all
        }
      end
    end
  end
end
