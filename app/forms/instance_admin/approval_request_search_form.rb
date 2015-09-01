class InstanceAdmin::ApprovalRequestSearchForm < SearchForm

  VALID_STATES = ['pending', 'rejected', 'approved', 'questioned']

  property :q, virtual: true
  property :date, virtual: true
  property :show, virtual: true

  def initialize
    super Object.new
  end

  def to_search_params
    result = { 
    }

    if q.present?
       result[:by_search_query] = ["%#{q}%"]
    end

    if date.present?
      result[:with_date] = [date_from_params]
    end

    if VALID_STATES.include?(show)
      result[show] = nil
    end

    result
  end

end
