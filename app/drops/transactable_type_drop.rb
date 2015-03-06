class TransactableTypeDrop < BaseDrop

  attr_reader :transactable_type

  delegate :id, :buyable?, to: :transactable_type

  def initialize(transactable_type)
    @transactable_type = transactable_type
  end

  def name
    @transactable_type.bookable_noun.presence || @transactable_type.name
  end

  def bookable_noun
    name
  end

  def bookable_noun_plural
    name.pluralize
  end

end

