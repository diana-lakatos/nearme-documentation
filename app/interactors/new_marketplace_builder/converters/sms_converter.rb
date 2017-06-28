# frozen_string_literal: true
module NewMarketplaceBuilder
  module Converters
    class SMSConverter < BaseConverter
      primary_key :path
      properties :body, :partial
      property :path

      def path(mailer)
        mailer.path
      end

      def set_path(mailer, path)
        mailer.path = path
      end

      def scope
        InstanceView.where(view_type: ['sms'], instance_id: @model.id)
      end

      def resource_name(liquid)
        return liquid.path unless liquid.partial
        "#{File.dirname(liquid.path)}/_#{File.basename(liquid.path)}"
      end

      def find_model_in_scope(scope, model_hash)
        scope.where(path: model_hash['path']).first_or_initialize
      end

      def default_values(_liquid)
        {
          transactable_types: TransactableType.all,
          format: 'text',
          view_type: 'sms',
          handler: 'liquid',
          partial: false,
          locales: Locale.all
        }
      end
    end
  end
end
