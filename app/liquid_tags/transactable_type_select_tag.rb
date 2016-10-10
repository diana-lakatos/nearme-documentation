class TransactableTypeSelectTag < SelectTag
  def name
    'transactable_type_id'
  end

  def klass
    TransactableType
  end

  def collection(context: nil)
    order = @param.present? ? @param.strip.to_sym : :asc
    options_from_collection_for_select(klass.all.order(name: order), :id, :name)
  end

  def classes
    %w(transactable-type-select-tag service-type-select-tag)
  end
end
