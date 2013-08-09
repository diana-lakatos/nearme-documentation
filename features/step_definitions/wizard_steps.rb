When /^I fill in valid space details$/ do
  fill_in 'Company name', with: 'International Secret Intelligence Service'
  page.execute_script "$('select#company_industry_ids option:first').prop('selected', true);"
  fill_in 'Location description', with: 'Our historic 11-story Southern Pacific Building, also known as "The Landmark", was completed in 1916. We are in the 172 m Spear Tower.'
  fill_in 'Location address', with: 'usa'
  page.execute_script "$('select#user_country_name option[value=\"New Zealand\"]').prop('selected', true).trigger('change');"
  fill_in 'Phone number', with: '844100999'
  select 'Business', from: 'Location type'
  fill_in "#{model!("instance").bookable_noun} name", with:'Desk'
  fill_in "#{model!("instance").bookable_noun} description", with:'We have a group of several shared desks available.'
  select 'Desk', from: "#{model!("instance").bookable_noun} type"
  fill_in 'Quantity available', with:1
  choose "Bookings are made by the day"

  image = File.join(Rails.root, *%w[features fixtures photos], "intern chair.jpg")
  attach_hidden_file('company[locations_attributes][0][listings_attributes][0][photos_attributes][0][image]', image)
  page.should_not have_content('Processing...')
end
