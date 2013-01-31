module Search


  def search_for(query)
    update_all_indexes
    if page.current_path =~ /search/
      save_and_open_page
    end
    fill_in "q", with: query
    if page.current_path =~ /search/
      save_and_open_page
      page.execute_script("$('.query').change()")
      save_and_open_page
    else
      click_link_or_button "Search" unless page.current_path =~ /search/
    end
  end


end

World(Search)
