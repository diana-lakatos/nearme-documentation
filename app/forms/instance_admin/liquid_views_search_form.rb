# frozen_string_literal: true
class InstanceAdmin::LiquidViewsSearchForm < SearchForm
  property :q, virtual: true

  def initialize
    super Object.new
  end

  def to_search_params
    result = {}

    result[:by_search_query] = ["%#{q}%"] if q.present?

    result
  end
end
