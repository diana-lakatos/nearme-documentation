module NewMarketplaceBuilder
  module Interactors
    class ExportInteractor
      EXPORTERS = {
        Converters::ContentHolderConverter => ['content_holders', 'liquid'],
        Converters::CustomModelTypeConverter => ['custom_model_types', 'yml'],
        Converters::CustomThemeConverter => ['custom_themes', 'theme_with_assets'],
        Converters::FormConfigurationConverter => ['form_configurations', 'liquid'],
        Converters::GraphQueryConverter => ['graph_queries', 'graphql'],
        Converters::InstanceProfileTypeConverter => ['instance_profile_types', 'yml'],
        Converters::LiquidViewConverter => ['liquid_views', 'liquid'],
        Converters::PageConverter => ['pages', 'liquid'],
        Converters::TransactableTypeConverter => ['transactable_types', 'yml'],
        Converters::TranslationConverter => ['translations', 'yml'],
        Converters::WorkflowConverter => ['workflows', 'yml'],
      }

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
          EXPORTERS.each do |converter, params|
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
