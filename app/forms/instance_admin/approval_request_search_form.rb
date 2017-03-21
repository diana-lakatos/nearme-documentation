# frozen_string_literal: true
class InstanceAdmin::ApprovalRequestSearchForm < SearchForm
  VALID_STATES = %w(pending rejected approved questioned).freeze

  property :q, virtual: true
  property :date, virtual: true
  property :show, virtual: true

  def initialize
    super Object.new
  end

  def to_search_params
    result = {
    }

    result[:by_search_query] = ["%#{q}%"] if q.present?

    result[:with_date] = [date_from_params] if date.present?

    result[show] = nil if VALID_STATES.include?(show)

    result
  end
end
