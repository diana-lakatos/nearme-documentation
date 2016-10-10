class CustomModelType::CustomModelTypeTranslationManager < TranslationManager
  def create_translations!
    create_plural_and_singular_translation('name', @object.name)
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
