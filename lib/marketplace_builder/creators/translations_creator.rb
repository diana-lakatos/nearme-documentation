# frozen_string_literal: true
module MarketplaceBuilder
  module Creators
    class TranslationsCreator < DataCreator
      def execute!
        locales = get_data
        locales.keys.each do |locale|
          logger.info "Translating locale: #{locale.upcase}"

          # keys are duplicated, so we canretain the same format of translation files as in the original Rails i18n files
          locales_hash = convert_hash_to_dot_notation(locales[locale][locale])
          locales_hash.each_pair do |key, value|
            create_translation(key, value, locale)
            logger.debug "Updating translation #{key}: #{value}"
          end
        end
      end

      private

      def source
        'translations'
      end

      def create_translation(key, value, locale)
        @instance.translations.where(
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
    end
  end
end
