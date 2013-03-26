Then /^I should be at the "(.*)" step$/ do |step_name|
  assert page.has_css?('.box > ul.space-wizard > li.current > span', :content => step_name)
end

When /^I fill in valid space details$/ do
  fill_in 'Location name', with: 'One Market Plaza'
  fill_in 'Location description', with: 'Our historic 11-story Southern Pacific Building, also known as "The Landmark", was completed in 1916. We are in the 172 m Spear Tower.'
  fill_in 'Location address', with: 'usa'
  select 'Business', from: 'Location type'
  fill_in 'Listing name', with:'Desk'
  fill_in 'Listing description', with:'We have a group of several shared desks available.'
  select 'Desk', from: 'Listing type'
  fill_in 'Quantity available', with:1
  attach_file 'company[locations_attributes][0][listings_attributes][0][photos_attributes][0][image]', "#{Rails.root}/test/assets/foobear.jpeg"
end
