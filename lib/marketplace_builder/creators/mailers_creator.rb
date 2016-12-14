# frozen_string_literal: true
module MarketplaceBuilder
  module Creators
    class MailersCreator < TemplatesCreator
      private

      def object_name
        'Mailer'
      end

      def create!(template)
        iv = InstanceView.where(instance_id: @instance.id, view_type: 'email', path: template.liquid_path, handler: 'liquid', format: 'text', partial: false).first_or_initialize
        iv.body = ActionView::Base.full_sanitizer.sanitize(template.body)
        iv.locales = Locale.all
        iv.transactable_types = TransactableType.all
        iv.save!
      end
    end
  end
end
