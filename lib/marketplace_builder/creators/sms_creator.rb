# frozen_string_literal: true
module MarketplaceBuilder
  module Creators
    class SMSCreator < TemplatesCreator
      private

      def object_name
        'SMS'
      end

      def cleanup!
        MarketplaceBuilder::Logger.info('TODO implement sms cleanup')
      end

      def create!(template)
        iv = InstanceView.where(instance_id: @instance.id, view_type: 'sms', path: template.liquid_path, handler: 'liquid', format: 'text', partial: false).first_or_initialize
        iv.locales = Locale.all
        iv.transactable_types = TransactableType.all
        iv.body = template.body
        iv.save!
      end
    end
  end
end
