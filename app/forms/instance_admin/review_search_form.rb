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

    if q.present?
      result[:by_search_query] = ["%#{q}%"]
    end

    if rating.present?
      result[:with_rating] = [rating]
    end

    if date.present?
      result[:with_date] = [date_from_params]
    end

    if transactable_type.present?
      result[:with_transactable_type] = [transactable_type]
    end

    result
  end

end
