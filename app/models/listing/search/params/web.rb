class Listing::Search::Params::Web < Listing::Search::Params
  attr_reader :location_string
  attr_reader :location_types_ids, :lntype, :lgtype, :lgpricing,
              :lntypes, :sort, :order, :dates, :start_date, :end_date, :display_dates, :lg_custom_attributes, :category_ids

  def initialize(options, transactable_type)
    super
    @transactable_type = transactable_type
    @location_types_ids = @options[:location_types_ids]
    @lntype = @options[:lntype].blank? ? nil : @options[:lntype]
    @lgtype = @options[:lgtype].blank? ? nil : @options[:lgtype]
    @lgpricing = @options[:lgpricing]
    @sort = (@options[:sort].presence || 'relevance').inquiry
    @order = (@options[:order].presence || 'ASC')
    @dates = (@options[:availability].present? && @options[:availability][:dates] && @options[:availability][:dates][:start].present? &&
              @options[:availability][:dates][:end].present?) ? @options[:availability][:dates] : nil
    @display_dates = (@options[:start_date].present? && @options[:end_date].present?) ?
      { start: @options[:start_date], end: @options[:end_date] } : nil
    @lg_custom_attributes = @options[:lg_custom_attributes] || {}
    @lg_custom_attributes.each do |key, value|
      @lg_custom_attributes[key] = (String === value ? value.split(',') : value).map(&:strip)
    end
    @category_ids = get_category_ids
  end

  def bounding_box
    if is_numeric?(@options[:nx]) && is_numeric?(@options[:sx]) && is_numeric?(@options[:ny]) && is_numeric?(@options[:sy])
      @bounding_box ||= {
                          top_right: {
                            lat: @options[:nx].to_f,
                            lon: @options[:ny].to_f
                          },
                          bottom_left: {
                            lat: @options[:sx].to_f,
                            lon: @options[:sy].to_f
                          }
                        }
    end
    super
  end

  def get_address_component(val, name_type = :long)
    if location.present?
      location.fetch_address_component(val, name_type)
    else
      options[val.to_sym]
    end
  end

  def get_category_ids
    categories = Category.where(id: @options[:category_ids].split(',')) if @options[:category_ids]
    if categories.present?
      if @transactable_type.category_search_type == 'OR'
        parent_ids = categories.map(&:parent_id)
        categories.map do |category|
          unless parent_ids.include?(category.id)
            category.self_and_descendants.map(&:id)
          end
        end.flatten.compact
      else
        categories.map(&:id)
      end
    else
      []
    end
  end

  def street
    get_address_component('street')
  end

  def suburb
    get_address_component('suburb')
  end

  def city
    get_address_component('city')
  end

  def state
    get_address_component('state')
  end

  def state_short
    get_address_component('state', :short)
  end

  def country
    get_address_component('country')
  end

  def is_united_states?
    query.to_s.downcase.include?('united states') || country == 'United States'
  end

  def postcode
    get_address_component('postcode')
  end

  def precise_address?
    state.present? && city.present?
  end

  def lntypes
    return [] if @lntype.nil?
    @lntypes ||= LocationType.where(id: @lntype.to_s.split(','))
  end

  def lntypes_filters
    lntypes.map(&:name).map(&:downcase)
  end

  def location_types_ids
    @location_types_ids.presence || (lntypes.empty? ? [] : lntypes.map(&:id)).map(&:to_s)
  end

  def lgtypes
    return [] if @lgtype.nil?
    @lgtypes ||= @lgtype.to_s.split(',')
  end

  def lgtypes_filters
    lgtypes
  end

  def lgpricing_filters
    @lgpricing.to_s.split(',')
  end

  def start_date
    return nil unless @dates
    @dates[:start]
  end

  def end_date
    return nil unless @dates
    @dates[:end]
  end

  def display_dates
    return { start: nil, end: nil } unless @display_dates
    @display_dates
  end
end
