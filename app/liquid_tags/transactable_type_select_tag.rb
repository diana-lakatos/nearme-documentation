# frozen_string_literal: true
# Usage example:
# ```
#   {% transactable_type_select %}
# ```
#
# Generates a select containing the services (Transactable Types) defined in the marketplace admin.
# The names in the select options are the Transactable Type names while the values are their IDs.
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
