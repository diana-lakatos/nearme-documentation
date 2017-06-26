# frozen_string_literal: true
module NewMarketplaceBuilder
  module Services
    class ConvertersConfig
      CONVERTERS_CONFIG = {
        'workflows' => {
          converter: Converters::WorkflowConverter,
          parser: Parsers::YamlParser
        },
        'liquid_views' => {
          converter: Converters::LiquidViewConverter,
          parser: Parsers::LiquidParser
        },
        'mailers' => {
          converter: Converters::MailerConverter,
          parser: Parsers::LiquidParser
        },
        'authorization_policies' => {
          converter: Converters::AuthorizationPolicyConverter,
          parser: Parsers::LiquidParser
        },
        'form_configurations' => {
          converter: Converters::FormConfigurationConverter,
          parser: Parsers::LiquidParser
        },
        'pages' => {
          converter: Converters::PageConverter,
          parser: Parsers::LiquidParser
        },
        'content_holders' => {
          converter: Converters::ContentHolderConverter,
          parser: Parsers::LiquidParser
        },
        'transactable_types' => {
          converter: Converters::TransactableTypeConverter,
          parser: Parsers::YamlParser
        },
        'reservation_types' => {
          converter: Converters::ReservationTypeConverter,
          parser: Parsers::YamlParser
        },
        'translations' => {
          converter: Converters::TranslationConverter,
          parser: Parsers::YamlParser
        },
        'graph_queries' => {
          converter: Converters::GraphQueryConverter,
          parser: Parsers::LiquidParser
        },
        'custom_themes.+\.yml' => {
          converter: Converters::CustomThemeConverter,
          parser: Parsers::YamlParser
        },
        'custom_themes\/default_custom_theme_assets' => {
          converter: Converters::CustomThemeAssetConverter,
          parser: Parsers::AssetParser
        },
        'instance_profile_types' => {
          converter: Converters::InstanceProfileTypeConverter,
          parser: Parsers::YamlParser
        },
        'custom_model_types' => {
          converter: Converters::CustomModelTypeConverter,
          parser: Parsers::YamlParser
        }
      }.freeze

      def self.get
        CONVERTERS_CONFIG
      end
    end
  end
end
