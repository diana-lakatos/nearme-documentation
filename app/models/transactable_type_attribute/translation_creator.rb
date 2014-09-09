class TransactableTypeAttribute::TranslationCreator

  def initialize(transactable_type_attribute)
    @tta = transactable_type_attribute
    @key_value_translations = {}
  end

  def create_translations!
    return unless should_create_translations?
    build_key_value_translations
    @key_value_translations.each do |key, value|
      translation = get_or_build_translation(key, value)
      if value.nil?
        translation.destroy if translation.persisted?
      else
        translation.value = value
        translation.save!
      end
    end
  end

  def build_key_value_translations
    case @tta.html_tag.try(:to_sym)
    when :input
      input_translations!
    when :select
      select_translations!
    end
  end

  def get_or_build_translation(key, value)
    Translation.where(locale: 'en', key: key, instance_id: @tta.instance_id).first.presence || Translation.new(locale: 'en', key: key, instance_id: @tta.instance_id)
  end

  def input_translations!
    translations_for_label!
    translations_for_hints!
    translations_for_placeholder!
  end

  def select_translations!
    translations_for_label!
    translations_for_hints!
    translations_for_prompt!
    translations_for_valid_values!
  end

  private

  def translations_for_label!
    @key_value_translations["simple_form.labels.listings.#{@tta.name}"] = @tta.label.presence || @tta.name
    @key_value_translations["simple_form.labels.listing.#{@tta.name}"] = @tta.label.presence || @tta.name
  end

  def translations_for_hints!
    @key_value_translations["simple_form.hints.listings.#{@tta.name}"] = @tta.hint.presence || nil
    @key_value_translations["simple_form.hints.listing.#{@tta.name}"] = @tta.hint.presence || nil
  end

  def translations_for_placeholder!
    @key_value_translations["simple_form.placeholders.listings.#{@tta.name}"] = @tta.placeholder
    @key_value_translations["simple_form.placeholders.listing.#{@tta.name}"] = @tta.placeholder
  end

  def translations_for_prompt!
    @key_value_translations[@tta.prompt_translation_key] = @tta.prompt || 'Please choose one'
  end

  def translations_for_valid_values!
    @tta.valid_values ||= []
    @tta.valid_values.each do |valid_value|
      @key_value_translations[@tta.valid_value_translation_key(valid_value)] = valid_value
    end
  end

  def should_create_translations?
    true
  end

end
