module SearchHelper
  # Special geolocation fields for the search form(s)
  def search_geofields
    %w(lat lng nx ny sx sy country state city suburb street postcode)
  end

  def search_availability_date(date)
    date ? I18n.l(date.to_date, format: :day_and_month) : ''
  end

  def search_availability_quantity
    params[:availability].present? && params[:availability][:quantity].to_i || 1
  end

  def search_amenities
    params[:amenities].present? && params[:amenities].map(&:to_i) || []
  end

  def search_price_min
    (params[:price].present? && params[:price][:min]) || 0
  end

  def search_price_max
    params[:price].present? && params[:price][:max] || PriceRange::MAX_SEARCHABLE_PRICE
  end

  def price_information(listing)
    if listing.schedule_booking?
      arr = []
      arr << "#{humanized_money_with_symbol(listing.fixed_price)} / #{listing.transactable_type.action_price_per_unit? ? I18n.t("simple_form.labels.transactable.price.per_unit") : I18n.t("simple_form.labels.transactable.price.fixed")}" if listing.fixed_price.to_f > 0
      arr << "#{humanized_money_with_symbol(listing.exclusive_price)} / #{I18n.t("simple_form.labels.transactable.price.exclusive_price")}" if listing.exclusive_price.to_f > 0
      arr.join(' | ')
    else
      if listing.action_hourly_booking? && !listing.hourly_price.to_f.zero?
        "#{I18n.t('reservations.from_price')} #{humanized_money_with_symbol(listing.hourly_price)} #{I18n.t('reservations.slash_per_hour')}"
      elsif !listing.daily_price.to_f.zero?
        "#{I18n.t('reservations.from_price')} #{humanized_money_with_symbol(listing.daily_price)} #{listing.overnight_booking? ? I18n.t('reservations.slash_per_night') : I18n.t('reservations.slash_per_day')}"
      elsif !listing.weekly_price.to_f.zero?
        "#{I18n.t('reservations.from_price')} #{humanized_money_with_symbol(listing.weekly_price)} #{I18n.t('reservations.slash_per_week')}"
      elsif !listing.monthly_price.to_f.zero?
        "#{I18n.t('reservations.from_price')} #{humanized_money_with_symbol(listing.monthly_price)} #{I18n.t('reservations.slash_per_month')}"
      end
    end
  end

  def individual_listing_price_information(listing, filter_pricing = [])
    if listing.schedule_booking?
      humanized_money_with_symbol(listing.fixed_price)
    else
      listing_price = listing.lowest_price_with_type(filter_pricing)
      if listing_price
        periods = {:monthly => 'month', :weekly => 'week', :daily => 'day', :hourly => 'hour'}
        "From <span>#{humanized_money_with_symbol(listing_price[0])}</span> / #{periods[listing_price[1]]}".html_safe
      end
    end
  end

  def meta_title_for_search(platform_context, search, transactable_type_name = '')
    location_types_names = search.try(:lntypes).blank? ? [] : search.lntypes.pluck(:name)

    title = params.try(:[], :lg_custom_attributes).try(:[], :listing_type)
    title = title.present? && title.respond_to?(:gsub) ? title.gsub(",", ", ") : (location_types_names.empty? ? transactable_type_name : '')

    title += %Q{#{location_types_names.join(', ')}}
    search_location = []
    search_location << search.city
    search_location << (search.is_united_states? ? search.state_short : search.state)
    search_location.reject!{|sl| sl.blank?}
    if not search_location.empty?
      title += %Q{ in #{search_location.join(', ')}}
    end

    title += if title.empty?
      I18n.t("metadata.search.title.search")
    else
      search_location.empty? ? I18n.t("metadata.search.title.in") : ', '
    end

    title += search.country.to_s

    title
  end

  def meta_description_for_search(platform_context, search)
    platform_context.theme.description
  end

  def display_search_result_subheader_for?(location)
    location.name != "#{location.company.name} @ #{location.street}"
  end

  def category_tree(root_category, current_category, max_level = 1, selected = [])
    return '' if max_level < 1 || root_category.children.empty?
    content_tag :ul, class: 'categories-list' do
      root_category.children.map do |category|
        content_tag :li, class: 'nav-item' do
          label = label_tag "category_#{category.id}", class: 'category-label' do
            content_tag(:span, check_box_tag("category_ids[]", category.id, selected.include?(category.id.to_s), {id: "category_#{category.id}", class: 'category-checkbox'}), class: 'category-checkbox-container') +
            content_tag(:span, category.translated_name, class: 'category-title')
          end
          label + category_tree(category, current_category, max_level - 1, selected)
        end
      end.join("\n").html_safe
    end
  end
end
