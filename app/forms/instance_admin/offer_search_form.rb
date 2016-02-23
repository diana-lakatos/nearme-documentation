class InstanceAdmin::OfferSearchForm < SearchForm

  property :q, virtual: true
  property :date, virtual: true
  property :filters, virtual: true
  property :item_type_id, virtual: true

  def initialize
    super Object.new
  end

  def to_search_params
    result = {}

    if q.present?
      result[:search_by_query] = [['name', 'summary', 'description', 'properties'], "%#{q}%"]
    end

    if date.present?
      result[:with_date] = [date_from_params]
    end

    if item_type_id.present?
      result[:for_transactable_type_id] = [item_type_id]
    end

    result
  end

end
