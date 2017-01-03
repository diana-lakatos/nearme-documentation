module MarketplaceBuilder
  module Serializers
    class TranslationsSerializer < BaseSerializer
      def export
        exported_files = []

        existing_locales.each do |locale|
          exported_files.push resource_name: "translations/#{locale}", exported_data: {locale => convert_translations_to_hash(locale)}
        end

        exported_files
      end

      private

      def existing_locales
        @existing_locales ||= @model.translations.group(:locale).select(:locale).map(&:locale)
      end

      def convert_translations_to_hash(locale)
        {}.tap do |hash|
          @model.translations.where(locale: locale).each do |translation|
            keys = translation.key.split('.')
            translation_hash = keys.push(translation.value).reverse.inject{|a,n| {n=>a}}
            hash.deep_merge! translation_hash
          end
        end
      end
    end
  end
end
