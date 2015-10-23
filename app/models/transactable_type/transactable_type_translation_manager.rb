class TransactableType::TransactableTypeTranslationManager < TranslationManager

  def create_translations!
    TransactableType::INTERNAL_FIELDS.each do |field|
      attribute = CustomAttributes::CustomAttribute.new(target: @object, instance: @object.instance, html_tag: :input, name: field.to_s)
      attribute.label = @object.instance.translations.find_by(key: attribute.label_key_was, locale: 'en').try(:value) || attribute.name.humanize
      attribute.hint = @object.instance.translations.find_by(key: attribute.hint_key_was, locale: 'en').try(:value)
      attribute.placeholder = @object.instance.translations.find_by(key: attribute.placeholder_key_was, locale: 'en').try(:value)
      attribute.create_translations
    end
  end

  def destroy_translations!
    ids = Translation.where('locale = ? AND instance_id = ? AND key like ?', 'en', @object.instance_id, "#{translation_namespace_was}.%").inject([]) do |ids_to_delete, t|
      if t.key  =~ /\A#{translation_namespace_was}\.(.+)\z/
        ids_to_delete << t.id
      end
      ids_to_delete
    end
    if translation_namespace_was != translation_namespace
      create_translations!
      Translation.destroy(ids)
    end
    create_plural_and_singular_translations!
  end

  def create_plural_and_singular_translations!
    create_plural_and_singular_translation('name', @object.bookable_noun.presence || @object.name)
    create_plural_and_singular_translation('lessor', @object.lessor)
    create_plural_and_singular_translation('lessee', @object.lessee)
  end

end

