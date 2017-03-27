# frozen_string_literal: true
class InstanceAdmin::ReviewSearchForm < SearchForm
  property :q, virtual: true
  property :rating, virtual: true
  property :date, virtual: true
  property :transactable_type, virtual: true

  def initialize
    super Object.new
  end

  def to_search_params
    result = {
    }

    result[:by_search_query] = ["%#{q}%"] if q.present?

    result[:with_rating] = [rating] if rating.present?

    result[:with_date] = [date_from_params] if date.present?

    result[:with_transactable_type] = [transactable_type] if transactable_type.present?

    result
  end
end
