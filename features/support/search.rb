module SearchHelpers
  def search_for(query, options={})
    update_all_indexes
    fill_in "q", with: query
    if start_date = options.fetch(:start_date, false)
      select_date(".availability-date-start", start_date)
    end

    if end_date = options.fetch(:end_date, false)
      select_date(".availability-date-end", end_date)
    end

    if page.current_path =~ /search/
      page.execute_script("$('#listing_search').submit()")
      wait_until_results_are_returned
    else
      click_link_or_button "Search"
    end
  end

  def select_date(locator, date)
    find("#{locator} .calendar").click
    wait_until_calendar_loads
    click_date(date)
  end


  def click_date(date)
    until page.has_content?(date.strftime("%B"))
      page.execute_script("$('.ui-datepicker-next').click();")
    end
    script ="$('td[data-handler=\"selectDay\"]:contains(\"#{date.day}\"):first').click()"
    page.execute_script(script)
  end

  def wait_until_calendar_loads
    wait_until_datepicker_finished_loading
  end

  def wait_until_results_are_returned
    wait_until(35) { page.has_no_selector?('.loading', visible: true) }
  end
end

World(SearchHelpers)
