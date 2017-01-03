module MarketplaceBuilder
  module Serializers
    class MailerSerializer < BaseSerializer
      resource_name -> (m) { "mailers/#{m.path}" }

      property :content

      def content(mail)
        mail.body
      end

      def scope
        InstanceView.where(view_type: 'email', instance_id: @model.id).all
      end
    end
  end
end
