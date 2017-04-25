require_relative 'basic'

module MarketplaceBuilder
  module ExporterTests
    class ShouldExportTranslations < Basic
      def initialize(instance)
        @instance = instance
      end

      def seed!
        @instance.translations.create! locale: 'en', key: 'first_test_key.nested.value', value: 'First test key nested value'
        @instance.translations.create! locale: 'en', key: 'second_test_key.nested.value', value: 'Second test key nested name'
        @instance.translations.create! locale: 'pl', key: 'first_test_key.value', value: 'Testowa nazwa'
      end

      def execute!
        yaml_content = read_exported_file('translations/en.yml')
        assert_equal yaml_content['en']['first_test_key']['nested']['value'], 'First test key nested value'
        assert_equal yaml_content['en']['second_test_key']['nested']['value'], 'Second test key nested name'

        yaml_content = read_exported_file('translations/pl.yml')
        assert_equal yaml_content['pl']['first_test_key']['value'], 'Testowa nazwa'
      end
    end
  end
end
