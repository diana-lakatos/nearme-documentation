# frozen_string_literal: true
module NewMarketplaceBuilder
  module Interactors
    class ExportInteractor
      EXPORTERS = {
        Converters::AuthorizationPolicyConverter => %w(authorization_policies liquid),
        Converters::ContentHolderConverter => %w(content_holders liquid),
        Converters::CustomModelTypeConverter => %w(custom_model_types yml),
        Converters::CustomThemeConverter => %w(custom_themes theme_with_assets),
        Converters::FormConfigurationConverter => %w(form_configurations liquid),
        Converters::GraphQueryConverter => %w(graph_queries graphql),
        Converters::InstanceProfileTypeConverter => %w(instance_profile_types yml),
        Converters::LiquidViewConverter => %w(liquid_views liquid),
        Converters::MailerConverter => %w(mailers liquid),
        Converters::PageConverter => %w(pages liquid),
        Converters::ReservationTypeConverter => %w(reservation_types yml),
        Converters::TransactableTypeConverter => %w(transactable_types yml),
        Converters::TranslationConverter => %w(translations yml),
        Converters::WorkflowConverter => %w(workflows yml)
      }.freeze

      def initialize(instance_id, destination)
        @instance_id = instance_id
        @destination = destination
      end

      def execute!
        export_all_resources.each do |converter, exported_resoruces|
          exported_resoruces.each do |exported_resource|
            serializer.serialize exported_resource, *EXPORTERS[converter]
          end
        end

        serializer.after_export
        manifest.update_md5
      end

      private

      def export_all_resources
        {}.tap do |exported_data|
          EXPORTERS.each do |converter, _params|
            exported_data[converter] = converter.new(instance).export
          end
        end
      end

      def instance
        @instance ||= Instance.find_by id: @instance_id
      end

      def manifest
        @manifest ||= Services::ManifestUpdater.new instance
      end

      def serializer
        @serializer ||= Factories::SerializerFactory.new(@destination).serializer(instance, manifest)
      end
    end
  end
end
