Then /^I should be at the "(.*)" step$/ do |step_name|
  assert page.has_css?('.box > ul.space-wizard > li.current > span', :content => step_name)
end

When /^I fill in valid space details$/ do
  fill_in 'Company name', with: 'International Secret Intelligence Service'
  page.execute_script "$('select#company_industry_ids option:first').prop('selected', true);"
  fill_in 'Location description', with: 'Our historic 11-story Southern Pacific Building, also known as "The Landmark", was completed in 1916. We are in the 172 m Spear Tower.'
  fill_in 'Location address', with: 'usa'
  page.execute_script "$('select#user_country_name option[value=\"New Zealand\"]').prop('selected', true).trigger('change');"
  fill_in 'Phone number', with: '844100999'
  select 'Business', from: 'Location type'
  fill_in 'Listing name', with:'Desk'
  fill_in 'Listing description', with:'We have a group of several shared desks available.'
  select 'Desk', from: 'Listing type'
  fill_in 'Quantity available', with:1
  choose "Bookings are made by the day"
  #attach_file 'company[locations_attributes][0][listings_attributes][0][photos_attributes][0][image]', "#{Rails.root}/test/assets/foobear.jpeg"
end
