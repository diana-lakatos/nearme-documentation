module NewMarketplaceBuilder
  module Services
    class ConvertersConfig
      CONVERTERS_CONFIG = {
        'workflows' => {
          converter: Converters::WorkflowConverter,
          parser: Parsers::YamlParser,
        },
        'liquid_views' => {
          converter: Converters::LiquidViewConverter,
          parser: Parsers::LiquidParser,
        },
        'pages' => {
          converter: Converters::PageConverter,
          parser: Parsers::LiquidParser
        },
        'transactable_types' => {
          converter: Converters::TransactableTypeConverter,
          parser: Parsers::YamlParser,
        },
        'translations' => {
          converter: Converters::TranslationConverter,
          parser: Parsers::YamlParser,
        },
        'custom_themes\/default_custom_theme_assets' => {
          converter: Converters::CustomThemeAssetConverter,
          parser: Parsers::AssetParser,
        },
        'custom_themes' => {
          converter: Converters::CustomThemeConverter,
          parser: Parsers::YamlParser,
        }
      }

      def self.get
        CONVERTERS_CONFIG
      end
    end
  end
end
