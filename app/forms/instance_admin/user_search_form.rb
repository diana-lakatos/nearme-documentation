class InstanceAdmin::UserSearchForm < SearchForm

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
      result[:by_search_query] = ["%#{q}%"]
    end

    if date.present?
      result[:with_date] = [date_from_params]
    end

    if item_type_id.present?
      result[:by_profile_type] = [item_type_id]
    end

    if filters.try(:include?, 'guest')
      result[:is_guest] = nil
    end

    if filters.try(:include?, 'host')
      result[:is_host] = nil
    end

    result
  end

end
