class InstanceAdmin::ProjectSearchForm < SearchForm

  property :q, virtual: true
  property :date, virtual: true
  property :filters, virtual: true

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

    result
  end

end
