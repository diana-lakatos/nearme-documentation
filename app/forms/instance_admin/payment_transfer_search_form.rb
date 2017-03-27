# frozen_string_literal: true
class InstanceAdmin::PaymentTransferSearchForm < SearchForm
  property :q, virtual: true
  property :created_at_date, virtual: true
  property :transferred_at_date, virtual: true
  property :filters, virtual: true

  def initialize
    super Object.new
  end

  def to_search_params
    result = {}

    result[:with_company_name] = q if q.present?

    result[:with_created_date] = [date_from_params(:created_at_date)] if created_at_date.present?

    result[:with_transferred_date] = [date_from_params(:transferred_at_date)] if transferred_at_date.present?

    result
  end
end
