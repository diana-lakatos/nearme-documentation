Then /^I see that amenity$/ do
  page.should have_content model!('amenity').name
end
