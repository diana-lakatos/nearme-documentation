class TransactableTypeDrop < BaseDrop

  attr_reader :transactable_type

  # id
  #   numeric identifier for this transactable type
  # show_page_enabled?
  #   returns true whether the "show" page has been enabled for this listing
  #   if enabled the listing will have a page separate from the location's
  # translation_key_suffix
  #   translation key suffix that is added to translations specific to this transactable type
  # translation_namespace
  #   translation namespace that is a prefix for translation keys specific to this transactable type
  # translated_bookable_noun
  #   translated name of this transactable type, based on current language
  delegate :id, :buyable?, :action_price_per_unit, :show_page_enabled?, :translated_bookable_noun, :translation_key_suffix, :translation_namespace, :slug, to: :transactable_type

  def initialize(transactable_type)
    @transactable_type = transactable_type
  end

  # name for the bookable item this transactable type represents (e.g. desk, room etc.)
  def name
    @transactable_type.translated_bookable_noun
  end

  # name for the bookable item this transactable type represents (e.g. desk, room etc.)
  def bookable_noun
    name
  end

  # name (plural) for the bookable item this transactable type represents (e.g. desks, rooms etc.)
  def bookable_noun_plural
    @transactable_type.translated_bookable_noun(10)
  end

  def to_json
    {
      id: @transactable_type.id,
      name: @transactable_type.name
    }.to_json
  end

  def lessor
    @transactable_type.translated_lessor
  end

  def lessee
    @transactable_type.translated_lessee
  end

  def lessors
    @transactable_type.translated_lessor(10)
  end

  def lessees
    @transactable_type.translated_lessee(10)
  end
end
