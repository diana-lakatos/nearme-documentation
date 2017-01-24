module MarketplaceBuilder
  module Serializers
    class SmsSerializer < BaseSerializer
      resource_name -> (m) { "sms/#{m.path}" }

      property :content

      def content(sms)
        sms.body
      end

      def scope
        InstanceView.where(view_type: 'sms', instance_id: @model.id).all
      end
    end
  end
end
