When /^I fill in valid space details$/ do
  attach_file_via_uploader
  fill_in 'Company name', with: 'International Secret Intelligence Service'
  page.execute_script "$('select#user_companies_attributes_0_industry_ids option:first').prop('selected', true);"
  fill_in 'Location description', with: 'Our historic 11-story Southern Pacific Building, also known as "The Landmark", was completed in 1916. We are in the 172 m Spear Tower.'
  fill_in 'user_companies_attributes_0_company_address_attributes_address', with: 'usa'
  fill_in 'Location name', with: 'name'
  fill_in 'user_companies_attributes_0_locations_attributes_0_location_address_attributes_address', with: 'usa'
  page.execute_script "$('select#user_country_name option[value=\"New Zealand\"]').prop('selected', true).trigger('change');"
  fill_in 'Phone number', with: '844100999'
  select 'Business', from: 'Location type'
  fill_in "Name", with:'Desk'
  fill_in "Description", with:'We have a group of several shared desks available.'
  fill_in 'Quantity', with:1
  page.execute_script "$('#user_companies_attributes_0_locations_attributes_0_listings_attributes_0_action_free_booking').prop('checked', true);"
  page.should_not have_content('Processing...')
end

When /^I partially fill in space details$/ do
  attach_file_via_uploader
  fill_in 'Company name', with: 'International Secret Intelligence Service'
  fill_in 'Location description', with: 'Our historic 11-story Southern Pacific Building, also known as "The Landmark", was completed in 1916. We are in the 172 m Spear Tower.'
  fill_in "Name", with:'Desk'
  page.should_not have_content('Processing...')
end

Then /^I should see shortened error messages$/ do
  page.should have_content('Price type must be free if all prices are zero')
  page.should have_content('Location type can\'t be blank')
  page.should have_content('Company name can\'t be blank')
  page.should have_content('Company industry can\'t be blank')
  page.should have_content('Company address can\'t be blank')
end

