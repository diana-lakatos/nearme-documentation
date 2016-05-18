When /^I fill in valid space details$/ do
  attach_file_via_uploader
  fill_in 'Company name', with: 'International Secret Intelligence Service'
  fill_in 'Location description', with: 'Our historic 11-story Southern Pacific Building, also known as "The Landmark", was completed in 1916. We are in the 172 m Spear Tower.'
  fill_in 'user_companies_attributes_0_company_address_attributes_address', with: 'usa'
  fill_in 'Location name', with: 'name'
  fill_in 'user_companies_attributes_0_locations_attributes_0_location_address_attributes_address', with: 'usa'
  choose_selectize '.user_country_name', 'New Zealand'
  fill_in 'user_phone', with: '844100999'
  choose_selectize '.user_country_name', 'Business'
  fill_in "Name", with:'Desk'
  fill_in "Description", with:'We have a group of several shared desks available.'
  fill_in 'Quantity', with:1
  page.execute_script "$('#user_companies_attributes_0_locations_attributes_0_listings_attributes_0_action_free_booking').click();"
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
  page.should have_content('Location address can\'t be blank')
end

