# frozen_string_literal: true
module NewMarketplaceBuilder
  module Converters
    class MailerConverter < BaseConverter
      primary_key :path
      properties :body, :path, :partial, :view_type

      def scope
        InstanceView.where(view_type: ['email'], instance_id: @model.id)
      end

      def resource_name(liquid)
        return liquid.path unless liquid.partial
        "#{File.dirname(liquid.path)}/_#{File.basename(liquid.path)}"
      end

      def default_values(_liquid)
        {
          transactable_types: TransactableType.all,
          format: 'html',
          view_type: 'email',
          handler: 'liquid',
          locales: Locale.all
        }
      end
    end
  end
end
