# frozen_string_literal: true
class InstanceAdmin::GroupSearchForm < SearchForm
  property :q, virtual: true
  property :date, virtual: true
  property :filters, virtual: true

  def initialize
    super Object.new
  end

  def to_search_params
    result = {}

    result[:by_search_query] = ["%#{q}%"] if q.present?

    result[:with_date] = [date_from_params] if date.present?

    result
  end
end
