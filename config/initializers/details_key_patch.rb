# Patch adds instance_id to DetailsKey used by ActionView cache
# this allows us to expire cache for certain views
module ActionView
  class LookupContext
    class DetailsKey #:nodoc:
      attr_accessor :instance_id, :i18n_locale, :custom_theme_id

      def self.get(details)
        if details[:formats]
          details = details.dup
          details[:formats] &= Mime::SET.symbols
        end
        @details_keys[details] ||= new(details)
      end

      def initialize(details)
        @hash = object_hash
        @instance_id = details[:instance_id]
        @custom_theme_id = details[:custom_theme_id]
        @i18n_locale = details[:i18n_locale]
      end
    end
  end
end
