# frozen_string_literal: true
class InstanceAdmin::TransactableSearchForm < SearchForm
  property :q, virtual: true
  property :date, virtual: true
  property :filters, virtual: true
  property :item_type_id, virtual: true

  def initialize
    super Object.new
  end

  def to_search_params
    result = {}

    result[:search_by_query] = [%w(name description properties), "%#{q}%"] if q.present?

    result[:with_date] = [date_from_params] if date.present?

    result[:for_transactable_type_id] = [item_type_id] if item_type_id.present?

    result
  end
end
