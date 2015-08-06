class TransactableTypeSelectTag < SelectTag
  def name
    'transactable_type_id'
  end

  def klass
    TransactableType
  end

  def collection
    order = @param.present? ? @param.strip.to_sym : :asc
    options_from_collection_for_select(klass.all.order(name: order), :id, :name)
  end

  def classes
    %w(transactable-type-select-tag)
  end
end

Liquid::Template.register_tag('transactable_type_select', TransactableTypeSelectTag)
