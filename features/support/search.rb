module Search


  def search_for(query)
    update_all_indexes
    fill_in "q", with: query
    if page.current_path =~ /search/
      page.execute_script("$('#listing_search').submit()")
    else
      click_link_or_button "Search" unless page.current_path =~ /search/
    end
  end


end

World(Search)
