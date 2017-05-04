# frozen_string_literal: true
module NewMarketplaceBuilder
  module Converters
    class TranslationConverter < BaseConverter
      def import(data_array)
        data_array.each do |data|
          locales_hash = convert_hash_to_dot_notation(data.values.first)
          locales_hash.each_pair do |key, value|
            create_translation(key, value, data.keys.first)
          end
        end
      end

      def export
        exported_files = []

        existing_locales.each do |locale|
          exported_files.push resource_name: locale, exported_data: {locale => convert_translations_to_hash(locale)}
        end

        exported_files
      end

      def scope
        Translation.all
      end

      private

      def create_translation(key, value, locale)
        @model.translations.where(
          locale: locale,
          key: key
        ).first_or_initialize.update!(value: value)
      end

      def convert_hash_to_dot_notation(hash, path = '')
        hash.each_with_object({}) do |(k, v), ret|
          key = path + k

          if v.is_a? Hash
            ret.merge! convert_hash_to_dot_notation(v, key + '.')
          else
            ret[key] = v
          end
        end
      end

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
