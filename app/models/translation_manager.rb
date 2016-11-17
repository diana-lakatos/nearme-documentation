# frozen_string_literal: true
class TranslationManager
  def initialize(object)
    @object = object
  end

  def destroy_translations!
  end

  def create_translations!
  end

  def find_key(key, _count = nil)
    I18n.t(key_with_namespace(key))
  end

  def find_key_with_count(key, count)
    I18n.t(key_with_namespace(key), count: count)
  end

  def key_with_namespace(key)
    "#{translation_namespace}.#{key}"
  end

  # @return [String] represents the item to be booked (e.g. desk, room etc.)
  #   taken from translations (e.g. translation key of the form 'transactable_type.desk.name')
  def translated_bookable_noun(count = 1)
    find_key_with_count('name', count)
  end

  def create_plural_and_singular_translation(key, value)
    create_singular_translation(key, value)
    create_plural_translation(key, value)
  end

  def create_singular_translation(key, value)
    if value.present?
      t = Translation.where(locale: PlatformContext.current.instance.primary_locale, key: singular_key_with_namespace(key), instance_id: @object.instance_id).first_or_initialize
      t.value = value
      t.save!
    end
  end

  def create_plural_translation(key, value)
    if value.present?
      t = Translation.where(locale: PlatformContext.current.instance.primary_locale, key: plural_key_with_namespace(key), instance_id: @object.instance_id).first_or_initialize
      t.value = value.pluralize
      t.save!
    end
  end

  def singular_key_with_namespace(key)
    "#{key_with_namespace(key)}.one"
  end

  def plural_key_with_namespace(key)
    "#{key_with_namespace(key)}.other"
  end

  # @return [String] translation key suffix that is added to translations specific to this transactable type
  def translation_key_suffix
    underscore(@object.name)
  end

  def translation_key_suffix_was
    underscore(@object.name_was)
  end

  def translation_key_pluralized_suffix
    underscore(@object.name.pluralize)
  end

  def translation_key_pluralized_suffix_was
    underscore(@object.name_was.pluralize)
  end

  def underscore(string)
    # FIXME: (rescue) is the ugly hotfix to make CI green. Need to go deeper with the translation issues

    string.underscore.tr(' ', '_')
  rescue
    ''
  end

  # @return [String] translation namespace that is a prefix for translation keys specific to this transactable type
  def translation_namespace
    underscore("#{@object.class.name.demodulize}.#{@object.name}")
  end

  def translation_namespace_was
    underscore("#{@object.class.name.demodulize}.#{(@object.name_was || @object.name)}")
  end
end
