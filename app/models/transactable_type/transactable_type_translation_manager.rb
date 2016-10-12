class TransactableType::TransactableTypeTranslationManager < TranslationManager
  def create_translations!
    TransactableType::INTERNAL_FIELDS.each do |field|
      attribute = CustomAttributes::CustomAttribute.new(target: @object, instance: @object.instance, html_tag: :input, name: field.to_s)
      attribute.label = @object.instance.translations.find_by(key: attribute.label_key_was, locale: PlatformContext.current.instance.primary_locale).try(:value) || attribute.name.humanize
      attribute.hint = @object.instance.translations.find_by(key: attribute.hint_key_was, locale: PlatformContext.current.instance.primary_locale).try(:value)
      attribute.placeholder = @object.instance.translations.find_by(key: attribute.placeholder_key_was, locale: PlatformContext.current.instance.primary_locale).try(:value)
      attribute.create_translations
    end
    create_plural_and_singular_translation('name', @object.bookable_noun.presence || @object.name)
    create_plural_and_singular_translation('lessor', @object.lessor)
    create_plural_and_singular_translation('lessee', @object.lessee)
  end

  def destroy_translations!
    ids = Translation.where('locale = ? AND instance_id = ? AND key like ?', PlatformContext.current.instance.primary_locale, @object.instance_id, "#{translation_namespace_was}.%").inject([]) do |ids_to_delete, t|
      ids_to_delete << t.id if t.key =~ /\A#{translation_namespace_was}\.(.+)\z/
      ids_to_delete
    end
    create_translations!
    @object.custom_attributes.reload.each(&:create_translations)
    Translation.destroy(ids) unless translation_namespace_was == translation_namespace
  end
end
