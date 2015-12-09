class InstanceProfileType::InstanceProfileTypeTranslationManager < TranslationManager

  def create_translations!
    create_plural_and_singular_translation('name', @object.name)
  end

end

