Given(/^saved search enabled$/) do
  TransactableType.find_each do |instance|
    instance.allow_save_search = true
    instance.save!
  end
end

When(/^I click save search button$/) do
  page.execute_script("$('#save-search-modal').show().addClass('in')")
  page.execute_script("$('#save-search-status-modal').show().addClass('in')")
  find('a[data-save-search]').click
end

When(/^I enter saved search title$/) do
  within('div[data-save-search-modal]') do
    fill_in :title, with: 'Saved search #1'
  end
end

When(/^I click on saved search dialog Save button$/) do
  find('button[data-save-search-submit]').click
  wait_for_ajax
end

Then(/^saved search is saved$/) do
  assert_equal 'Saved search #1', SavedSearch.last.title
end

When(/^there is existing saved search$/) do
  FactoryGirl.create(:saved_search,
    title: 'The title',
    user: user,
    query: '?loc=Auckland&query=&transactable_type_id=1&buyable=false'
  )
end

When(/^I edit the search title$/) do
  saved_search = SavedSearch.first
  page.execute_script("$('div.controls').css('visibility', 'visible')")
  click_link 'Edit'
  fill_in 'title', with: "New title\n"
  wait_for_ajax
end

Then(/^saved search is updated$/) do
  assert_equal 'New title', SavedSearch.first.title
end

When(/^I edit the search title setting title to already existing one$/) do
  saved_search = SavedSearch.first
  FactoryGirl.create(:saved_search,
    user: saved_search.user,
    title: 'Another title',
    query: '?loc=Auckland&query=&transactable_type_id=1&buyable=false'
  )

  page.execute_script("$('div.controls').css('visibility', 'visible')")
  click_link 'Edit'
  fill_in 'title', with: "Another title\n"
  wait_for_ajax
end

Then(/^saved search is not updated$/) do
  assert_equal 'The title', SavedSearch.first.title
end

When(/^I delete saved search$/) do
  page.execute_script("$('div.controls').css('visibility', 'visible')")
  click_link 'Delete'
end

Then(/^page redirects back to the saved searches page$/) do
  assert_equal dashboard_saved_searches_path, current_path
  assert_equal 0, SavedSearch.count
end

When(/^I click on search title$/) do
  click_link 'The title'
end
