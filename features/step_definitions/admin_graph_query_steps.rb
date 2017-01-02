When(/^I create graph query$/) do
  click_link 'Add Graph Query'
  fill_in 'Name', with: 'users'
  find_by_id('graph_query_query_string', visible: false).set '{users(take: 1){name}}'

  click_button 'Save'
end

Then(/^I should see tag to insert graph query in liquid$/) do
  page.should have_content("{% query_graph 'users', result_name: g %}")
end


Given(/^I have users graph query defined$/) do
  @graph_query = FactoryGirl.create(:graph_query)
end

When(/^I remove users graph query$/) do
  click_button 'Destroy'
end

Then(/^I should see that query was removed$/) do
  page.should have_content('Query removed')
end
