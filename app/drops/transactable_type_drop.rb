class TransactableTypeDrop < BaseDrop

  attr_reader :transactable_type

  # id
  #   numeric identifier for this transactable type
  # show_page_enabled?
  #   returns true whether the "show" page has been enabled for this listing
  #   if enabled the listing will have a page separate from the location's
  # translation_key_suffix
  #   translation key suffix that is added to translations specific to this transactable type
  delegate :id, :buyable?, :show_page_enabled?, :translation_key_suffix, to: :transactable_type

  def initialize(transactable_type)
    @transactable_type = transactable_type
  end

  # name for the bookable item this transactable type represents (e.g. desk, room etc.)
  def name
    @transactable_type.bookable_noun.presence || @transactable_type.name
  end

  # name for the bookable item this transactable type represents (e.g. desk, room etc.)
  def bookable_noun
    name
  end

  # name (plural) for the bookable item this transactable type represents (e.g. desks, rooms etc.)
  def bookable_noun_plural
    name.pluralize
  end

end

