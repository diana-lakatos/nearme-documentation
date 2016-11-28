# frozen_string_literal: true
class InstanceAdmin::ProjectSearchForm < SearchForm
  property :q, virtual: true
  property :date, virtual: true
  property :filters, virtual: true

  def initialize
    super Object.new
  end

  def to_search_params
    result = {}

    result[:search_by_query] = [[:name, :description], q] if q.present?

    result[:with_date] = [date_from_params] if date.present?

    result
  end
end
