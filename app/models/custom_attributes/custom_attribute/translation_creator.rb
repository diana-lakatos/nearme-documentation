module CustomAttributes
  class CustomAttribute::TranslationCreator

    def initialize(custom_attribute)
      @custom_attribute = custom_attribute
      @key_value_translations = {}
    end

    def create_translations!
      return unless should_create_translations?
      build_key_value_translations
      @key_value_translations.each do |key, value|
        translation = get_or_build_translation(key)
        if value.nil?
          translation.destroy if translation.persisted?
        else
          translation.value = value
          translation.save!
        end
      end
    end

    def build_key_value_translations
      case @custom_attribute.html_tag.try(:to_sym)
      when :input, :textarea
        input_translations!
      when :switch, :check_box
        switch_or_check_box!
      when :radio_buttons, :check_box_list
        radio_buttons_or_checkbox_list!
      when :select
        select_translations!
      end
    end

    def get_or_build_translation(key)
      translation = Translation.where(locale: PlatformContext.current.instance.primary_locale, key: key, instance_id: @custom_attribute.instance_id).first_or_initialize
      translation.skip_expire_cache = true
      translation
    end

    def input_translations!
      translations_for_label!
      translations_for_hints!
      translations_for_placeholder!
    end

    def switch_or_check_box!
      translations_for_label!
      translations_for_hints!
    end

    def radio_buttons_or_checkbox_list!
      translations_for_label!
      translations_for_hints!
      translations_for_valid_values!
    end

    def select_translations!
      translations_for_label!
      translations_for_hints!
      translations_for_prompt!
      translations_for_valid_values!
    end

    private

    def translations_for_label!
      @key_value_translations[@custom_attribute.label_key] = @custom_attribute.label.presence || @custom_attribute.name
    end

    def translations_for_hints!
      @key_value_translations[@custom_attribute.hint_key] = @custom_attribute.hint
    end

    def translations_for_placeholder!
      @key_value_translations[@custom_attribute.placeholder_key] = @custom_attribute.placeholder
    end

    def translations_for_prompt!
      @key_value_translations[@custom_attribute.prompt_key] = @custom_attribute.prompt || 'Please choose one'
    end

    def translations_for_valid_values!
      @custom_attribute.valid_values ||= []
      @custom_attribute.valid_values.each do |valid_value|
        @key_value_translations[@custom_attribute.valid_value_translation_key(valid_value)] = valid_value
      end
    end

    def should_create_translations?
      true
    end

  end
end
