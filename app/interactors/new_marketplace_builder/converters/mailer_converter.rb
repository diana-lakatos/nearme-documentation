# frozen_string_literal: true
module NewMarketplaceBuilder
  module Converters
    class MailerConverter < BaseConverter
      primary_key :path
      properties :body, :partial, :view_type, :format
      property :path

      def path(mailer)
        mailer.path
      end

      def set_path(mailer, path)
        mailer.path = raw_path(path)
      end

      def scope
        InstanceView.where(view_type: ['email'], instance_id: @model.id)
      end

      def resource_name(liquid)
        return "#{liquid.path}.#{liquid.format}"unless liquid.partial
        "#{File.dirname(liquid.path)}/_#{File.basename(liquid.path)}.#{liquid.format}"
      end

      def find_model_in_scope(scope, model_hash)
        scope.where(path: raw_path(model_hash['path']), format: model_hash['format']).first_or_initialize
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

      private

      def raw_path(path)
        path.gsub('.html', '').gsub('.text', '')
      end
    end
  end
end
