module SearchHelpers
  def search_for(query, options={})
    fill_in "q", with: query
    select_address_form_autocomplete

    if start_date = options.fetch(:start_date, false)
      select_date(".availability-date-start", start_date)
    end

    if end_date = options.fetch(:end_date, false)
      select_date(".availability-date-end", end_date)
    end


    if page.current_path =~ /search/
      page.execute_script("$('#listing_search form').submit()")
      wait_until_results_are_returned
    else
      click_link_or_button "Search"
    end
  end

  def select_address_form_autocomplete
    page.execute_script("$('#search').trigger('keypress')")
    return unless page.has_css?('.pac-container', visible: true)
    first_result = all('.pac-container .pac-item').first

    if first_result
      first_result.click
      page.should have_css("#lat:not([value=''])", visible: false)
    end
  end

  def select_date(locator, date)
    ensure_datepicker_open(locator)
    select_datepicker_date(date)
  end

  def wait_until_results_are_returned
    page.should_not have_selector('.loading', visible: true)
  end
end

World(SearchHelpers)
