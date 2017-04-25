module MarketplaceBuilder
  module BuilderTests
    class ShouldImportTranslations < ActiveSupport::TestCase
      def initialize(instance)
        @instance = instance
      end

      def execute!
        assert_includes @instance.translations.where(locale: :en).pluck(:key, :value),
          ['first_test_key', 'First test name']

        assert_includes @instance.translations.where(locale: :en).pluck(:key, :value),
          ['second_test_key', 'Second test name']

        assert_includes @instance.translations.where(locale: :pl).pluck(:key, :value),
          ['first_test_key', 'Testowa nazwa']

        assert_includes @instance.translations.where(locale: :pl).pluck(:key, :value),
          ['second_test_key', 'Druga testowa nazwa']
      end
    end
  end
end
