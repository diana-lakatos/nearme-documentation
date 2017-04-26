# frozen_string_literal: true
class InstanceAdmin::WorkflowAlertsSearchForm < SearchForm
  property :q, virtual: true
  property :from, virtual: true
  property :reply_to, virtual: true

  def initialize
    super Object.new
  end

  def to_search_params
    result = {}

    result[:by_search_query] = ["%#{q}%"] if q.present?

    result[:by_from_field] = ["%#{from}%"] if from.present?

    result[:by_reply_to_field] = ["%#{reply_to}%"] if reply_to.present?

    result
  end
end
